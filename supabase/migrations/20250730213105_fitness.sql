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

COMMENT ON TYPE public.workout_schedule_type IS 'Schedule type for workouts, used to determine when the workout should be performed.';

--
-- Tables
--

-- EXERCISES
CREATE TABLE public.exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    name TEXT NOT NULL,
    description TEXT,
    rest_timer INTEGER DEFAULT 0, -- Seconds
    checklist TEXT[],
    is_active BOOLEAN NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE public.exercises IS 'Stores exercises with their details.';

CREATE TABLE public.exercise_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    checked BOOLEAN[] DEFAULT ARRAY[]::BOOLEAN[],
    note TEXT,
    is_active BOOLEAN NOT NULL DEFAULT FALSE
);

COMMENT ON TABLE public.exercise_results IS 'Stores individual exercise results with status and notes.';

-- WORKOUTS
CREATE TABLE public.workouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    name TEXT NOT NULL,
    description TEXT,
    schedule public.workout_schedule_type[],
    is_active BOOLEAN NOT NULL DEFAULT FALSE
    -- workout_exercises
);

COMMENT ON TABLE public.workouts IS 'Stores workouts with their schedule.';

CREATE TABLE public.workout_exercises (
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    position INTEGER NOT NULL,
    UNIQUE (workout_id, position),
    PRIMARY KEY (workout_id, exercise_id)
);

COMMENT ON TABLE public.workout_exercises IS 'Join table linking workouts and exercises, defining the order of exercises in a workout.';

CREATE TABLE public.workout_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    finished_at TIMESTAMPTZ,
    note TEXT,
    is_active BOOLEAN NOT NULL DEFAULT FALSE
    -- workout_result_exercise_results
);

COMMENT ON TABLE public.workout_results IS 'Stores individual workout results with the finished date.';

CREATE TABLE public.workout_result_exercise_results (
    workout_result_id UUID NOT NULL REFERENCES public.workout_results(id) ON DELETE CASCADE,
    exercise_result_id UUID NOT NULL REFERENCES public.exercise_results(id) ON DELETE CASCADE,
    position INTEGER NOT NULL,
    UNIQUE (workout_result_id, position),
    PRIMARY KEY (workout_result_id, exercise_result_id)
);

COMMENT ON TABLE public.workout_result_exercise_results IS 'Join table linking workout results and exercise results, defining the order of exercise results in a workout result.';

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
    OR TRIM(TO_CHAR(CURRENT_DATE, 'Day')) = ANY(w.schedule::text[])
    OR (
      'Weekly' = ANY(w.schedule::text[])
      AND (
        wr.created_at IS NULL
        OR wr.created_at::date < (CURRENT_DATE - INTERVAL '7 days')
      )
    )
  )
ORDER BY w.is_active DESC, w.name;

COMMENT ON VIEW public.todays_workouts IS 'View for the today''s workouts page.';

CREATE OR REPLACE VIEW public.table_counts
WITH (security_invoker=on)
AS
SELECT
  (SELECT COUNT(*) FROM public.workouts) AS workouts,
  (SELECT COUNT(*) FROM public.exercises) AS exercises,
  (SELECT COUNT(*) FROM public.workout_results) AS workout_results,
  (SELECT COUNT(*) FROM public.exercise_results) AS exercise_results;

COMMENT ON VIEW public.table_counts IS 'View for user-specific table counts.';

CREATE OR REPLACE VIEW public.exercise_options
WITH (security_invoker=on)
AS
SELECT
  id AS value,
  name || ' (' || LEFT(id::text, 4) || '*' || ')' AS label,
  FALSE AS disable -- Don't disable any options even if they are active
FROM public.exercises;

COMMENT ON VIEW public.exercise_options IS 'View for exercise options used in forms.';

CREATE OR REPLACE VIEW public.workouts_table
WITH (security_invoker=on)
AS
SELECT
  w.*,
  (SELECT COUNT(*) FROM public.workout_exercises we WHERE we.workout_id = w.id) AS exercise_count,
  (SELECT COUNT(*) FROM public.workout_results wr WHERE wr.workout_id = w.id) AS workout_result_count
FROM public.workouts w;

COMMENT ON VIEW public.workouts_table IS 'View for workouts table, providing workout details and counts of exercises and results.';

CREATE OR REPLACE VIEW public.exercises_table
WITH (security_invoker=on)
AS
SELECT
  e.*,
  (SELECT COUNT(*) FROM public.workout_exercises we WHERE we.exercise_id = e.id) AS workout_count,
  (SELECT COUNT(*) FROM public.exercise_results er WHERE er.exercise_id = e.id) AS exercise_result_count
FROM public.exercises e;

COMMENT ON VIEW public.exercises_table IS 'View for exercises table, providing exercise details and counts of workouts and results.';

CREATE OR REPLACE VIEW public.workout_results_table
WITH (security_invoker=on)
AS
SELECT
  wr.*,
  w.name AS workout_name,
  EXTRACT(EPOCH FROM (wr.finished_at - wr.created_at)) AS duration_seconds
FROM public.workout_results wr
JOIN public.workouts w
ON w.id = wr.workout_id;

COMMENT ON VIEW public.workout_results_table IS 'View for workout results table, providing workout result details and counts of exercise results.';

CREATE OR REPLACE VIEW public.exercise_results_table
WITH (security_invoker=on)
AS
SELECT
  er.*,
  e.name AS exercise_name
FROM public.exercise_results er
JOIN public.exercises e
ON e.id = er.exercise_id;

COMMENT ON VIEW public.exercise_results_table IS 'View for exercise results table, providing exercise result details and counts of workout results.';

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
ALTER publication supabase_realtime ADD TABLE exercises;
ALTER publication supabase_realtime ADD TABLE workout_results;
ALTER publication supabase_realtime ADD TABLE exercise_results;

--
-- RLS Policies
--

-- exercises
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated user can select"
ON public.exercises
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Authenticated user can insert"
ON public.exercises
FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Authenticated user can update"
ON public.exercises
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Authenticated user can delete"
ON public.exercises
FOR DELETE
TO authenticated
USING (true);

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

-- exercise_results
ALTER TABLE public.exercise_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated user can select"
ON public.exercise_results
FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Authenticated user can insert"
ON public.exercise_results
FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Authenticated user can update"
ON public.exercise_results
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Authenticated user can delete"
ON public.exercise_results
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

-- workout_exercises
ALTER TABLE public.workout_exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated user can select"
ON public.workout_exercises
FOR SELECT
TO authenticated
USING (workout_id IN (SELECT id FROM public.workouts));

CREATE POLICY "Authenticated user can insert"
ON public.workout_exercises
FOR INSERT
TO authenticated
WITH CHECK (workout_id IN (SELECT id FROM public.workouts));

CREATE POLICY "Authenticated user can update"
ON public.workout_exercises
FOR UPDATE
TO authenticated
USING (workout_id IN (SELECT id FROM public.workouts))
WITH CHECK (workout_id IN (SELECT id FROM public.workouts));

CREATE POLICY "Authenticated user can delete"
ON public.workout_exercises
FOR DELETE
TO authenticated
USING (workout_id IN (SELECT id FROM public.workouts));

-- workout_result_exercise_results
ALTER TABLE public.workout_result_exercise_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated user can select"
ON public.workout_result_exercise_results
FOR SELECT
TO authenticated
USING (workout_result_id IN (SELECT id FROM public.workout_results));

CREATE POLICY "Authenticated user can insert"
ON public.workout_result_exercise_results
FOR INSERT
TO authenticated
WITH CHECK (workout_result_id IN (SELECT id FROM public.workout_results));

CREATE POLICY "Authenticated user can update"
ON public.workout_result_exercise_results
FOR UPDATE
TO authenticated
USING (workout_result_id IN (SELECT id FROM public.workout_results))
WITH CHECK (workout_result_id IN (SELECT id FROM public.workout_results));

CREATE POLICY "Authenticated user can delete"
ON public.workout_result_exercise_results
FOR DELETE
TO authenticated
USING (workout_result_id IN (SELECT id FROM public.workout_results));

--
-- Functions
--

-- Fetches all needed data for workout inspection dialog and the edit dialog
CREATE OR REPLACE FUNCTION public.inspect_workout(w_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
  workout JSONB;
  exercises JSONB;
  last_workout_result JSONB;
BEGIN
  -- workout
  SELECT to_jsonb(w)
  INTO workout
  FROM public.workouts w
  WHERE w.id = w_id;

  -- exercises
  SELECT COALESCE(jsonb_agg(jsonb_build_object('id', e.id, 'name', e.name) ORDER BY we.position), '[]'::jsonb)
  INTO exercises
  FROM public.workout_exercises we
  JOIN public.exercises e
  ON e.id = we.exercise_id
  WHERE we.workout_id = w_id;

  -- last_workout_result
  SELECT jsonb_build_object(
    'id', wr.id,
    'created_at', wr.created_at,
    'finished_at', wr.finished_at,
    'duration_seconds', EXTRACT(EPOCH FROM (wr.finished_at - wr.created_at)),
    'note', wr.note
  )
  INTO last_workout_result
  FROM public.workout_results wr
  WHERE wr.workout_id = w_id
  ORDER BY wr.created_at DESC
  LIMIT 1;

  RETURN jsonb_build_object(
    'workout', workout,
    'exercises', exercises,
    'last_workout_result', last_workout_result
  );
END;
$$;

COMMENT ON FUNCTION public.inspect_workout(w_id UUID) IS 'Function for inspect workout dialogs. Provides selection of all relevant data for a workout, including exercises and last workout result.';

CREATE OR REPLACE FUNCTION public.create_workout(
  w_name TEXT,
  w_description TEXT DEFAULT NULL,
  w_created_at TIMESTAMPTZ DEFAULT (NOW() AT TIME ZONE 'utc'),
  w_schedule public.workout_schedule_type[] DEFAULT ARRAY[]::workout_schedule_type[],
  w_exercise_ids UUID[] DEFAULT ARRAY[]::UUID[]
)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
  new_workout_id UUID;
BEGIN
  -- Insert workout
  INSERT INTO public.workouts (name, description, created_at, schedule)
  VALUES (w_name, w_description, w_created_at, w_schedule)
  RETURNING id INTO new_workout_id;

  -- Insert workout_exercises
  IF array_length(w_exercise_ids, 1) > 0 THEN
    FOR i IN 1..array_length(w_exercise_ids, 1) LOOP
      INSERT INTO public.workout_exercises (workout_id, exercise_id, position)
      VALUES (new_workout_id, w_exercise_ids[i], i - 1);
    END LOOP;
  END IF;
END;
$$;

COMMENT ON FUNCTION public.create_workout(w_name TEXT, w_description TEXT, w_created_at TIMESTAMPTZ, w_schedule public.workout_schedule_type[], w_exercise_ids UUID[]) IS 'Function creates a workout and its associated workout exercises.';

CREATE OR REPLACE FUNCTION public.edit_workout(
  w_id UUID,
  w_name TEXT,
  w_description TEXT DEFAULT NULL,
  w_created_at TIMESTAMPTZ DEFAULT (NOW() AT TIME ZONE 'utc'),
  w_schedule public.workout_schedule_type[] DEFAULT ARRAY[]::workout_schedule_type[],
  w_exercise_ids UUID[] DEFAULT ARRAY[]::UUID[]
)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  -- Update workout
  UPDATE public.workouts
  SET name = w_name,
      description = w_description,
      created_at = w_created_at,
      schedule = w_schedule
  WHERE id = w_id;

  -- Remove existing workout_exercises
  DELETE FROM public.workout_exercises WHERE workout_id = w_id;

  -- Insert new workout_exercises
  IF array_length(w_exercise_ids, 1) > 0 THEN
    FOR i IN 1..array_length(w_exercise_ids, 1) LOOP
      INSERT INTO public.workout_exercises (workout_id, exercise_id, position)
      VALUES (w_id, w_exercise_ids[i], i - 1);
    END LOOP;
  END IF;
END;
$$;

COMMENT ON FUNCTION public.edit_workout(w_id UUID, w_name TEXT, w_description TEXT, w_created_at TIMESTAMPTZ, w_schedule public.workout_schedule_type[], w_exercise_ids UUID[]) IS 'Function updates a workout and replaces its workout exercises.';

-- Fetches all needed data for exercise inspection dialog and the edit dialog
CREATE OR REPLACE FUNCTION public.inspect_exercise(e_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
  exercise JSONB;
  total_results JSONB;
  workouts_used JSONB;
BEGIN
  -- exercise
  SELECT to_jsonb(e)
  INTO exercise
  FROM public.exercises e
  WHERE e.id = e_id;

  -- Count of exercise results
  SELECT COUNT(*)
  INTO total_results
  FROM public.exercise_results er
  WHERE er.exercise_id = e_id;

  -- List of workouts that use this exercise
  SELECT COALESCE(jsonb_agg(jsonb_build_object('id', w.id, 'name', w.name)), '[]'::jsonb)
  INTO workouts_used
  FROM public.workout_exercises we
  JOIN public.workouts w ON w.id = we.workout_id
  WHERE we.exercise_id = e_id;

  RETURN jsonb_build_object(
    'exercise', exercise,
    'total_results', total_results,
    'workouts_used', workouts_used
  );
END;
$$;

COMMENT ON FUNCTION public.inspect_exercise(e_id UUID) IS 'Function for inspect exercise dialogs. Provides selection of all relevant data for an exercise, including count of results and workouts that use the exercise.';

CREATE OR REPLACE FUNCTION public.create_exercise(
  e_name TEXT,
  e_description TEXT,
  e_created_at TIMESTAMPTZ,
  e_rest_timer INTEGER,
  e_checklist TEXT[]
)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  -- Insert exercise
  INSERT INTO public.exercises (name, description, created_at, rest_timer, checklist)
  VALUES (e_name, e_description, e_created_at, e_rest_timer, e_checklist);
END;
$$;

COMMENT ON FUNCTION public.create_exercise(e_name TEXT, e_description TEXT, e_created_at TIMESTAMPTZ, e_rest_timer INTEGER, e_checklist TEXT[]) IS 'Function creates an exercise with the provided details.';

CREATE OR REPLACE FUNCTION public.edit_exercise(
  e_id UUID,
  e_name TEXT,
  e_description TEXT,
  e_rest_timer INTEGER,
  e_checklist TEXT[]
)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  -- Update exercise
  UPDATE public.exercises
  SET name = e_name,
      description = e_description,
      rest_timer = e_rest_timer,
      checklist = e_checklist
  WHERE id = e_id;
END;
$$;

COMMENT ON FUNCTION public.edit_exercise(e_id UUID, e_name TEXT, e_description TEXT, e_rest_timer INTEGER, e_checklist TEXT[]) IS 'Function updates an exercise with the provided details.';

CREATE OR REPLACE FUNCTION public.inspect_workout_result(wr_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
  workout_result JSONB;
  workout JSONB;
BEGIN
  -- workout_result
  SELECT to_jsonb(wr) || jsonb_build_object(
    'duration_seconds', CASE
      WHEN wr.finished_at IS NOT NULL THEN EXTRACT(EPOCH FROM (wr.finished_at - wr.created_at))::integer
      ELSE NULL
    END
  )
  INTO workout_result
  FROM public.workout_results wr
  WHERE wr.id = wr_id;

  -- workout
  SELECT to_jsonb(w)
  INTO workout
  FROM public.workouts w
  WHERE w.id = (workout_result->>'workout_id')::UUID;

  RETURN jsonb_build_object(
    'workout_result', workout_result,
    'workout', workout
  );
END;
$$;

COMMENT ON FUNCTION public.inspect_workout_result(wr_id UUID) IS 'Function for inspect workout result dialogs. Provides selection of all relevant data for a workout result, including the associated workout.';

CREATE OR REPLACE FUNCTION public.edit_workout_result(wr_id UUID, wr_created_at TIMESTAMPTZ, wr_finished_at TIMESTAMPTZ, wr_note TEXT)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  -- Update workout_result
  UPDATE public.workout_results
  SET note = wr_note,
      created_at = wr_created_at,
      finished_at = wr_finished_at
  WHERE id = wr_id;
END;
$$;

COMMENT ON FUNCTION public.edit_workout_result(wr_id UUID, wr_created_at TIMESTAMPTZ, wr_finished_at TIMESTAMPTZ, wr_note TEXT) IS 'Function updates a workout result with the provided details.';

CREATE OR REPLACE FUNCTION public.inspect_exercise_result(er_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
  exercise_result JSONB;
  exercise JSONB;
BEGIN
  -- exercise_result
  SELECT to_jsonb(er)
  INTO exercise_result
  FROM public.exercise_results er
  WHERE er.id = er_id;

  -- exercise
  SELECT to_jsonb(e)
  INTO exercise
  FROM public.exercises e
  WHERE e.id = (exercise_result->>'exercise_id')::UUID;
  RETURN jsonb_build_object(
    'exercise_result', exercise_result,
    'exercise', exercise
  );
END;
$$;

COMMENT ON FUNCTION public.inspect_exercise_result(er_id UUID) IS 'Function for inspect exercise result dialogs. Provides selection of all relevant data for an exercise result, including the associated exercise.';

-- TODO: edit_exercise_result

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
