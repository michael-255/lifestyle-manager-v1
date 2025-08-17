--
-- ENUMS
--

CREATE TYPE public.exercise_type AS ENUM (
    'Checklist',
    'Weightlifting',
    'Sided Weightlifting'
);

COMMENT ON TYPE public.exercise_type IS 'Type of exercise, used to determine what the user can record.';

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
    user_id UUID NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    name TEXT NOT NULL,
    description TEXT,
    rest_timer INTEGER DEFAULT 0, -- Seconds
    type public.exercise_type NOT NULL,
    checklist_labels TEXT[], -- Checklist: Ordered list of labels
    initial_sets INTEGER, -- Weightlifting and Sided Weightlifting
    is_locked BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE public.exercises IS 'Stores exercises with rows for each exercise type data.';

CREATE TABLE public.exercise_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    note TEXT,
    is_locked BOOLEAN DEFAULT FALSE
    -- exercise_result_items
);

COMMENT ON TABLE public.exercise_results IS 'Stores individual exercise results with rows for each exercise type data.';

CREATE TABLE public.exercise_result_item (
    exercise_result_id UUID NOT NULL REFERENCES public.exercise_results(id) ON DELETE CASCADE,
    position INTEGER NOT NULL,
    is_checked BOOLEAN,         -- Checklist
    reps INTEGER,               -- Weightlifting
    weight NUMERIC,             -- Weightlifting
    left_reps INTEGER,          -- Sided Weightlifting
    left_weight NUMERIC,        -- Sided Weightlifting
    right_reps INTEGER,         -- Sided Weightlifting
    right_weight NUMERIC,       -- Sided Weightlifting
    PRIMARY KEY (exercise_result_id, position)
);

COMMENT ON TABLE public.exercise_result_item IS 'Stores individual items for exercise results, supporting all exercise types.';

-- WORKOUTS
CREATE TABLE public.workouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    name TEXT NOT NULL,
    description TEXT,
    schedule public.workout_schedule_type[],
    is_locked BOOLEAN DEFAULT FALSE
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
    user_id UUID NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    finished_at TIMESTAMPTZ,
    note TEXT,
    is_locked BOOLEAN DEFAULT FALSE
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
  w.is_locked,
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
  w.user_id = auth.uid()
  AND (
    'Daily' = ANY(w.schedule::text[])
    OR TRIM(TO_CHAR(CURRENT_DATE, 'Day')) = ANY(w.schedule::text[])
    OR (
      'Weekly' = ANY(w.schedule::text[])
      AND (
        wr.created_at IS NULL
        OR wr.created_at::date < (CURRENT_DATE - INTERVAL '7 days')
      )
    )
  );

COMMENT ON VIEW public.todays_workouts IS 'View for the today''s workouts page.';

CREATE OR REPLACE VIEW public.table_counts
WITH (security_invoker=on)
AS
SELECT
  (SELECT COUNT(*) FROM public.workouts WHERE user_id = auth.uid()) AS workouts,
  (SELECT COUNT(*) FROM public.exercises WHERE user_id = auth.uid()) AS exercises,
  (SELECT COUNT(*) FROM public.workout_results WHERE user_id = auth.uid()) AS workout_results,
  (SELECT COUNT(*) FROM public.exercise_results WHERE user_id = auth.uid()) AS exercise_results;

COMMENT ON VIEW public.table_counts IS 'View for user-specific table counts.';

CREATE OR REPLACE VIEW public.workout_exercise_options
WITH (security_invoker=on)
AS
SELECT
  id AS value,
  name || ' (' || LEFT(id::text, 4) || '*' || ')' AS label,
  is_locked AS disable
FROM public.exercises
WHERE user_id = auth.uid();

COMMENT ON VIEW public.workout_exercise_options IS 'View for workout exercise options used in forms.';

CREATE OR REPLACE VIEW public.workouts_table
WITH (security_invoker=on)
AS
SELECT
  w.id,
  w.created_at,
  w.name,
  w.description,
  w.schedule,
  w.is_locked,
  (SELECT COUNT(*) FROM public.workout_exercises we WHERE we.workout_id = w.id) AS exercise_count,
  (SELECT COUNT(*) FROM public.workout_results wr WHERE wr.workout_id = w.id) AS workout_result_count
FROM public.workouts w
WHERE w.user_id = auth.uid();

COMMENT ON VIEW public.workouts_table IS 'View for workouts table, providing workout details and counts of exercises and results.';

CREATE OR REPLACE VIEW public.exercises_table
WITH (security_invoker=on)
AS
SELECT
  e.id,
  e.created_at,
  e.name,
  e.description,
  e.rest_timer,
  e.type,
  e.checklist_labels,
  e.initial_sets,
  e.is_locked,
  (SELECT COUNT(*) FROM public.workout_exercises we WHERE we.exercise_id = e.id) AS workout_count,
  (SELECT COUNT(*) FROM public.exercise_results er WHERE er.exercise_id = e.id) AS exercise_result_count
FROM public.exercises e
WHERE e.user_id = auth.uid();

COMMENT ON VIEW public.exercises_table IS 'View for exercises table, providing exercise details and counts of workouts and results.';

CREATE OR REPLACE VIEW public.workout_results_table
WITH (security_invoker=on)
AS
SELECT
  wr.id,
  wr.created_at,
  wr.finished_at,
  wr.note,
  wr.is_locked,
  w.id AS workout_id,
  w.name AS workout_name,
  EXTRACT(EPOCH FROM (wr.finished_at - wr.created_at)) AS duration_seconds
FROM public.workout_results wr
JOIN public.workouts w ON w.id = wr.workout_id
WHERE wr.user_id = auth.uid();

COMMENT ON VIEW public.workout_results_table IS 'View for workout results table, providing workout result details and counts of exercise results.';

CREATE OR REPLACE VIEW public.exercise_results_table
WITH (security_invoker=on)
AS
SELECT
  er.id,
  er.created_at,
  er.note,
  er.is_locked,
  e.id AS exercise_id,
  e.name AS exercise_name,
  e.type AS exercise_type
FROM public.exercise_results er
JOIN public.exercises e ON e.id = er.exercise_id
WHERE er.user_id = auth.uid();

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
USING (user_id = (select auth.uid()));

CREATE POLICY "Authenticated user can insert"
ON public.exercises
FOR INSERT
TO authenticated
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated user can update"
ON public.exercises
FOR UPDATE
TO authenticated
USING (user_id = (select auth.uid()))
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated user can delete"
ON public.exercises
FOR DELETE
TO authenticated
USING (user_id = (select auth.uid()));

-- workouts
ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated user can select"
ON public.workouts
FOR SELECT
TO authenticated
USING (user_id = (select auth.uid()));

CREATE POLICY "Authenticated user can insert"
ON public.workouts
FOR INSERT
TO authenticated
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated user can update"
ON public.workouts
FOR UPDATE
TO authenticated
USING (user_id = (select auth.uid()))
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated user can delete"
ON public.workouts
FOR DELETE
TO authenticated
USING (user_id = (select auth.uid()));

-- exercise_results
ALTER TABLE public.exercise_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated user can select"
ON public.exercise_results
FOR SELECT
TO authenticated
USING (user_id = (select auth.uid()));

CREATE POLICY "Authenticated user can insert"
ON public.exercise_results
FOR INSERT
TO authenticated
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated user can update"
ON public.exercise_results
FOR UPDATE
TO authenticated
USING (user_id = (select auth.uid()))
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated user can delete"
ON public.exercise_results
FOR DELETE
TO authenticated
USING (user_id = (select auth.uid()));

-- workout_results
ALTER TABLE public.workout_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated user can select"
ON public.workout_results
FOR SELECT
TO authenticated
USING (user_id = (select auth.uid()));

CREATE POLICY "Authenticated user can insert"
ON public.workout_results
FOR INSERT
TO authenticated
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated user can update"
ON public.workout_results
FOR UPDATE
TO authenticated
USING (user_id = (select auth.uid()))
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated user can delete"
ON public.workout_results
FOR DELETE
TO authenticated
USING (user_id = (select auth.uid()));

-- workout_exercises
ALTER TABLE public.workout_exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated user can select"
ON public.workout_exercises
FOR SELECT
TO authenticated
USING (workout_id IN (SELECT id FROM public.workouts WHERE user_id = (select auth.uid())));

CREATE POLICY "Authenticated user can insert"
ON public.workout_exercises
FOR INSERT
TO authenticated
WITH CHECK (workout_id IN (SELECT id FROM public.workouts WHERE user_id = (select auth.uid())));

CREATE POLICY "Authenticated user can update"
ON public.workout_exercises
FOR UPDATE
TO authenticated
USING (workout_id IN (SELECT id FROM public.workouts WHERE user_id = (select auth.uid())))
WITH CHECK (workout_id IN (SELECT id FROM public.workouts WHERE user_id = (select auth.uid())));

CREATE POLICY "Authenticated user can delete"
ON public.workout_exercises
FOR DELETE
TO authenticated
USING (workout_id IN (SELECT id FROM public.workouts WHERE user_id = (select auth.uid())));

-- workout_result_exercise_results
ALTER TABLE public.workout_result_exercise_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated user can select"
ON public.workout_result_exercise_results
FOR SELECT
TO authenticated
USING (workout_result_id IN (SELECT id FROM public.workout_results WHERE user_id = (select auth.uid())));

CREATE POLICY "Authenticated user can insert"
ON public.workout_result_exercise_results
FOR INSERT
TO authenticated
WITH CHECK (workout_result_id IN (SELECT id FROM public.workout_results WHERE user_id = (select auth.uid())));

CREATE POLICY "Authenticated user can update"
ON public.workout_result_exercise_results
FOR UPDATE
TO authenticated
USING (workout_result_id IN (SELECT id FROM public.workout_results WHERE user_id = (select auth.uid())))
WITH CHECK (workout_result_id IN (SELECT id FROM public.workout_results WHERE user_id = (select auth.uid())));

CREATE POLICY "Authenticated user can delete"
ON public.workout_result_exercise_results
FOR DELETE
TO authenticated
USING (workout_result_id IN (SELECT id FROM public.workout_results WHERE user_id = (select auth.uid())));

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
  WHERE w.id = w_id
  AND w.user_id = auth.uid();

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
  INSERT INTO public.workouts (name, description, created_at, schedule, user_id)
  VALUES (w_name, w_description, w_created_at, w_schedule, auth.uid())
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
DECLARE
  is_locked BOOLEAN;
BEGIN
  -- Check if workout is locked
  SELECT w.is_locked INTO is_locked
  FROM public.workouts w
  WHERE w.id = w_id
  AND w.user_id = auth.uid();

  IF is_locked THEN
    RAISE EXCEPTION 'Workout is locked and cannot be edited';
  END IF;

  -- Update workout
  UPDATE public.workouts
  SET name = w_name,
      description = w_description,
      created_at = w_created_at,
      schedule = w_schedule
  WHERE id = w_id
  AND user_id = auth.uid();

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
  WHERE e.id = e_id
  AND e.user_id = auth.uid();

  -- Count of exercise results
  SELECT COUNT(*)
  INTO total_results
  FROM public.exercise_results er
  WHERE er.exercise_id = e_id
  AND er.user_id = auth.uid();

  -- List of workouts that use this exercise
  SELECT COALESCE(jsonb_agg(jsonb_build_object('id', w.id, 'name', w.name)), '[]'::jsonb)
  INTO workouts_used
  FROM public.workout_exercises we
  JOIN public.workouts w ON w.id = we.workout_id
  WHERE we.exercise_id = e_id
  AND w.user_id = auth.uid();

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
  e_rest_timer INTEGER,
  e_type public.exercise_type,
  e_checklist_labels TEXT[],
  e_initial_sets INTEGER
)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  -- Insert exercise
  INSERT INTO public.exercises (name, description, rest_timer, type, checklist_labels, initial_sets, user_id)
  VALUES (e_name, e_description, e_rest_timer, e_type, e_checklist_labels, e_initial_sets, auth.uid());
END;
$$;

COMMENT ON FUNCTION public.create_exercise(e_name TEXT, e_description TEXT, e_rest_timer INTEGER, e_type public.exercise_type, e_checklist_labels TEXT[], e_initial_sets INTEGER) IS 'Function creates an exercise with the provided details.';

CREATE OR REPLACE FUNCTION public.edit_exercise(
  e_id UUID,
  e_name TEXT,
  e_description TEXT,
  e_rest_timer INTEGER,
  e_initial_sets INTEGER
)
RETURNS void
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
  is_locked BOOLEAN;
BEGIN
  -- Check if exercise is locked
  SELECT e.is_locked INTO is_locked
  FROM public.exercises e
  WHERE e.id = e_id
  AND e.user_id = auth.uid();

  IF is_locked THEN
    RAISE EXCEPTION 'Exercise is locked and cannot be edited';
  END IF;

  -- Update exercise
  UPDATE public.exercises
  SET name = e_name,
      description = e_description,
      rest_timer = e_rest_timer,
      initial_sets = e_initial_sets
  WHERE id = e_id
  AND user_id = auth.uid();
END;
$$;

COMMENT ON FUNCTION public.edit_exercise(e_id UUID, e_name TEXT, e_description TEXT, e_rest_timer INTEGER, e_initial_sets INTEGER) IS 'Function updates an exercise with the provided details.';

-- inspect_workout_result

-- create_workout_result

-- edit_workout_result

-- inspect_exercise_result

-- create_exercise_result

-- edit_exercise_result

-- start_workout

-- finish_workout
