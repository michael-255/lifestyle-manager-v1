--
-- ENUMS
--

CREATE TYPE public.workout_schedule_type AS ENUM (
    -- By Time
    'Daily',
    'Weekly',
    -- By Weekday
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
);

--
-- Tables
--

CREATE TABLE public.workouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    name TEXT NOT NULL,
    description TEXT,
    schedule public.workout_schedule_type[],
    exercises JSONB DEFAULT NULL, -- name, description, rest_timer, checklist[]
    is_active BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE public.workout_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    finished_at TIMESTAMPTZ,
    note TEXT,
    exercise_results JSONB DEFAULT NULL, -- note, checked[]
    is_active BOOLEAN NOT NULL DEFAULT FALSE
);

--
-- Views
--

CREATE OR REPLACE VIEW public.todays_workouts
WITH (security_invoker=on)
AS
SELECT
  w.id,
  w.name,
  w.is_active,
  wr.created_at AS last_created_at,
  wr.note AS last_note,
  (EXTRACT(EPOCH FROM (wr.finished_at - wr.created_at))::integer) AS last_duration_seconds
FROM public.workouts w
LEFT JOIN LATERAL (
  SELECT
    wr.created_at,
    wr.finished_at,
    wr.note
  FROM public.workout_results wr
  WHERE wr.workout_id = w.id
  ORDER BY wr.created_at DESC
  LIMIT 1
) wr ON TRUE
WHERE
  (
    'Daily' = ANY(w.schedule::text[])
    OR TRIM(TO_CHAR(CURRENT_DATE, 'FMDay')) = ANY(w.schedule::text[])
    OR (
      'Weekly' = ANY(w.schedule::text[])
      AND (
        wr.created_at IS NULL
        OR wr.created_at::date < (CURRENT_DATE - INTERVAL '7 days')
      )
    )
  )
ORDER BY w.is_active DESC, w.name;

CREATE OR REPLACE VIEW public.table_record_counts
WITH (security_invoker=on)
AS
SELECT
  (SELECT COUNT(*) FROM public.workouts) AS workouts,
  (SELECT COUNT(*) FROM public.workout_results) AS workout_results;

--
-- Realtime
--

-- TODO
BEGIN;
-- remove the supabase_realtime publication
DROP publication if exists supabase_realtime;
-- re-create the supabase_realtime publication with no tables
CREATE publication supabase_realtime;
COMMIT;
-- update this to match your tables
ALTER publication supabase_realtime ADD TABLE workouts;
ALTER publication supabase_realtime ADD TABLE workout_results;

--
-- RLS Policies
--

-- workouts
ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated user can select"
ON public.workouts
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Authenticated user can insert"
ON public.workouts
FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Authenticated user can update"
ON public.workouts
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Authenticated user can delete"
ON public.workouts
FOR DELETE
TO authenticated
USING (true);

-- workout_results
ALTER TABLE public.workout_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated user can select"
ON public.workout_results
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Authenticated user can insert"
ON public.workout_results
FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Authenticated user can update"
ON public.workout_results
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Authenticated user can delete"
ON public.workout_results
FOR DELETE
TO authenticated
USING (true);

--
-- Functions
--

CREATE OR REPLACE FUNCTION public.get_active_workout()
RETURNS JSONB
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
  workout_data JSONB;
  workout_result_data JSONB;
BEGIN
  -- Fetch workout
  SELECT to_jsonb(w)
  INTO workout_data
  FROM public.workouts w
  WHERE w.is_active = TRUE
  LIMIT 1;

  -- Fetch associated workout result
  SELECT to_jsonb(wr)
  INTO workout_result_data
  FROM public.workout_results wr
  WHERE wr.is_active = TRUE
  LIMIT 1;

  RETURN jsonb_build_object(
    'workout', workout_data,
    'workout_result', workout_result_data
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.start_active_workout(w_id UUID)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  -- Set workout to active
  UPDATE public.workouts
  SET is_active = TRUE
  WHERE id = w_id;

  -- Create workout result
  INSERT INTO public.workout_results (workout_id, is_active)
  VALUES (w_id, TRUE);
END;
$$;

CREATE OR REPLACE FUNCTION public.replace_active_workout(w_id UUID)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  -- Delete the active workout result
  DELETE FROM public.workout_results
  WHERE is_active = TRUE;

  -- Set the workout to inactive
  UPDATE public.workouts
  SET is_active = FALSE
  WHERE is_active = TRUE;

  -- Start the new workout by calling the start_active_workout RPC function
  PERFORM public.start_active_workout(w_id);
END;
$$;

CREATE OR REPLACE FUNCTION public.finish_active_workout(w_id UUID, wr_note TEXT, wr_exercise_results JSONB)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  -- Set the workout to inactive
  UPDATE public.workouts
  SET is_active = FALSE
  WHERE is_active = TRUE;

  -- Update active workout result with finished_at timestamp, exercise_results, and set to inactive
  UPDATE public.workout_results
  SET finished_at = NOW() AT TIME ZONE 'utc',
      note = wr_note,
      exercise_results = wr_exercise_results,
      is_active = FALSE
  WHERE workout_id = w_id
  AND is_active = TRUE;
END;
$$;

CREATE OR REPLACE FUNCTION public.cancel_active_workout()
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  -- Delete the active workout result
  DELETE FROM public.workout_results
  WHERE is_active = TRUE;

  -- Set the workout to inactive
  UPDATE public.workouts
  SET is_active = FALSE
  WHERE is_active = TRUE;
END;
$$;
