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
    exercises JSONB, -- name, description, rest_timer, checklist[]
    is_active BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE public.workout_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    finished_at TIMESTAMPTZ,
    note TEXT,
    exercise_results JSONB, -- note, checked[]
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

CREATE OR REPLACE FUNCTION public.start_workout(w_id UUID)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
  exercises_data JSONB;
BEGIN
  -- Fetch exercises
  SELECT COALESCE(jsonb_agg(to_jsonb(e) ORDER BY we.position), '[]'::jsonb)
  INTO exercises_data
  FROM public.workout_exercises we
  JOIN public.exercises e ON e.id = we.exercise_id
  WHERE we.workout_id = w_id;

  -- Create new workout result
  INSERT INTO public.workout_results (workout_id, is_active)
  VALUES (w_id, TRUE);

  -- Create exercise results for each exercise in the workout
  IF jsonb_array_length(exercises_data) > 0 THEN
    FOR i IN 0..jsonb_array_length(exercises_data) - 1 LOOP
      INSERT INTO public.exercise_results (exercise_id, is_active)
      VALUES ((exercises_data->i->>'id')::UUID, TRUE);
    END LOOP;
  END IF;

  -- Set workout to active
  UPDATE public.workouts
  SET is_active = TRUE
  WHERE id = w_id;

  -- Set exercises to active
  UPDATE public.exercises
  SET is_active = TRUE
  WHERE id IN (SELECT (exercises_data->i->>'id')::UUID FROM generate_series(0, jsonb_array_length(exercises_data) - 1) AS i);
END;
$$;

COMMENT ON FUNCTION public.start_workout(w_id UUID) IS 'Function starts a workout, creating a new workout result and exercise results, and setting the workout and exercises to active.';

CREATE OR REPLACE FUNCTION public.replace_workout(w_id UUID)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  -- Delete the active workout result
  DELETE FROM public.workout_results
  WHERE is_active = TRUE;

  -- Delete the active exercise results
  DELETE FROM public.exercise_results
  WHERE is_active = TRUE;

  -- Set the workout to inactive
  UPDATE public.workouts
  SET is_active = FALSE
  WHERE is_active = TRUE;

  -- Set the exercises to inactive
  UPDATE public.exercises
  SET is_active = FALSE
  WHERE is_active = TRUE;

  -- Start the workout by calling the start_workout RPC function
  PERFORM public.start_workout(w_id);
END;
$$;

COMMENT ON FUNCTION public.replace_workout(w_id UUID) IS 'Function replaces the current active workout with a new one, deleting the previous workout results and setting the workout and exercises to inactive before starting the new workout.';

CREATE OR REPLACE FUNCTION public.get_active_workout(w_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
  workout_data JSONB;
  exercises_data JSONB;
  workout_result_data JSONB;
  exercise_results_data JSONB;
BEGIN
  -- Fetch workout
  SELECT to_jsonb(w)
  INTO workout_data
  FROM public.workouts w
  WHERE w.id = w_id;

  -- Fetch exercises
  SELECT COALESCE(jsonb_agg(to_jsonb(e) ORDER BY we.position), '[]'::jsonb)
  INTO exercises_data
  FROM public.workout_exercises we
  JOIN public.exercises e ON e.id = we.exercise_id
  WHERE we.workout_id = w_id;

  -- Fetch associated workout result (full row)
  SELECT to_jsonb(wr)
  INTO workout_result_data
  FROM public.workout_results wr
  WHERE wr.workout_id = w_id
  AND wr.is_active = TRUE
  LIMIT 1;

  -- Fetch associated exercise results (full rows)
  SELECT COALESCE(jsonb_agg(to_jsonb(er)), '[]'::jsonb)
  INTO exercise_results_data
  FROM public.exercise_results er
  WHERE er.exercise_id IN (SELECT (exercises_data->i->>'id')::UUID FROM generate_series(0, jsonb_array_length(exercises_data) - 1) AS i)
  AND er.is_active = TRUE;

  RETURN jsonb_build_object(
    'workout', workout_data,
    'exercises', exercises_data,
    'workout_result', workout_result_data,
    'exercise_results', exercise_results_data
  );
END;
$$;

COMMENT ON FUNCTION public.get_active_workout(w_id UUID) IS 'Function retrieves the active workout and its exercises, including the latest workout result and exercise results.';

CREATE OR REPLACE FUNCTION public.finish_workout(w_id UUID)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  -- Set workout.is_active to FALSE
  UPDATE public.workouts
  SET is_active = FALSE
  WHERE id = w_id
  AND is_active = TRUE;

  -- Set associated exercises.is_active to FALSE
  UPDATE public.exercises
  SET is_active = FALSE
  WHERE id IN (
    SELECT we.exercise_id
    FROM public.workout_exercises we
    WHERE we.workout_id = w_id
  )
  AND is_active = TRUE;

  -- Update active workout result with finished_at timestamp and set is_active to FALSE
  UPDATE public.workout_results
  SET finished_at = NOW() AT TIME ZONE 'utc',
      is_active = FALSE
  WHERE workout_id = w_id
  AND is_active = TRUE;

  -- Update active exercise results is_active to FALSE
  UPDATE public.exercise_results
  SET is_active = FALSE
  WHERE exercise_id IN (
    SELECT we.exercise_id
    FROM public.workout_exercises we
    WHERE we.workout_id = w_id
  )
  AND is_active = TRUE;
END;
$$;

COMMENT ON FUNCTION public.finish_workout(w_id UUID) IS 'Function finishes the active workout, setting the workout and exercises to inactive, updating the workout result with the finished timestamp, and setting exercise results to inactive.';
