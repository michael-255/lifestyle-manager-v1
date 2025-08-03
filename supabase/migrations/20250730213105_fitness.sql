--
-- ENUMS
--

CREATE TYPE public.exercise_type AS ENUM (
    'Checklist',
    'Cardio',
    'Weightlifting',
    'Sided Weightlifting',
    'Climbing'
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
-- Main Tables
--

CREATE TABLE public.exercises (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    name TEXT NOT NULL,
    description TEXT,
    type public.exercise_type NOT NULL,
    checklist_labels TEXT[],
    default_sets INTEGER DEFAULT 1,
    rest_timer INTEGER,
    is_locked BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE public.exercises IS 'Stores exercises, including their type and data.';
COMMENT ON COLUMN public.exercises.id IS 'Unique identifier for the exercise.';
COMMENT ON COLUMN public.exercises.user_id IS 'ID of the user who owns the exercise.';
COMMENT ON COLUMN public.exercises.created_at IS 'Timestamp when the exercise was created.';
COMMENT ON COLUMN public.exercises.name IS 'Name of the exercise.';
COMMENT ON COLUMN public.exercises.description IS 'Description of the exercise.';
COMMENT ON COLUMN public.exercises.type IS 'Type of the exercise.';
COMMENT ON COLUMN public.exercises.checklist_labels IS 'Labels for checklist exercises, used to define the items in the checklist.';
COMMENT ON COLUMN public.exercises.default_sets IS 'Default number of sets for the exercise (if any).';
COMMENT ON COLUMN public.exercises.rest_timer IS 'Rest timer duration in seconds (if any).';
COMMENT ON COLUMN public.exercises.is_locked IS 'Indicates if the exercise is locked for editing.';

CREATE TABLE public.workouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    name TEXT NOT NULL,
    description TEXT,
    schedule public.workout_schedule_type[],
    is_locked BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE public.workouts IS 'Stores workouts, including their schedule.';
COMMENT ON COLUMN public.workouts.id IS 'Unique identifier for the workout.';
COMMENT ON COLUMN public.workouts.user_id IS 'ID of the user who owns the workout.';
COMMENT ON COLUMN public.workouts.created_at IS 'Timestamp when the workout was created.';
COMMENT ON COLUMN public.workouts.name IS 'Name of the workout.';
COMMENT ON COLUMN public.workouts.description IS 'Description of the workout.';
COMMENT ON COLUMN public.workouts.schedule IS 'Schedule for the workout, indicating when it should be performed.';
COMMENT ON COLUMN public.workouts.is_locked IS 'Indicates if the workout is locked for editing.';

CREATE TABLE public.exercise_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    note TEXT,
    data JSONB, -- For all potential exercise data
    is_locked BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE public.exercise_results IS 'Stores individual exercise results.';
COMMENT ON COLUMN public.exercise_results.id IS 'Unique identifier for the exercise result.';
COMMENT ON COLUMN public.exercise_results.user_id IS 'ID of the user who owns the exercise result.';
COMMENT ON COLUMN public.exercise_results.exercise_id IS 'ID of the exercise for which the result is recorded.';
COMMENT ON COLUMN public.exercise_results.created_at IS 'Timestamp when the exercise result was created.';
COMMENT ON COLUMN public.exercise_results.note IS 'Optional note for the exercise result.';
COMMENT ON COLUMN public.exercise_results.data IS 'JSONB data containing all potential exercise data.';
COMMENT ON COLUMN public.exercise_results.is_locked IS 'Indicates if the exercise result is locked for editing.';

CREATE TABLE public.workout_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    finished_at TIMESTAMPTZ,
    note TEXT,
    is_locked BOOLEAN DEFAULT FALSE
);

COMMENT ON TABLE public.workout_results IS 'Stores individual workout results.';
COMMENT ON COLUMN public.workout_results.id IS 'Unique identifier for the workout result.';
COMMENT ON COLUMN public.workout_results.user_id IS 'ID of the user who owns the workout result.';
COMMENT ON COLUMN public.workout_results.workout_id IS 'ID of the workout for which the result is recorded.';
COMMENT ON COLUMN public.workout_results.created_at IS 'Timestamp when the workout result was created.';
COMMENT ON COLUMN public.workout_results.finished_at IS 'Timestamp when the workout was finished (if applicable).';
COMMENT ON COLUMN public.workout_results.note IS 'Optional note for the workout result.';
COMMENT ON COLUMN public.workout_results.is_locked IS 'Indicates if the workout result is locked for editing.';

--
-- Join Tables
--

CREATE TABLE public.workout_exercises (
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    position INTEGER NOT NULL,
    UNIQUE (workout_id, position),
    PRIMARY KEY (workout_id, exercise_id)
);

COMMENT ON TABLE public.workout_exercises IS 'Join table linking workouts and exercises, defining the order of exercises in a workout.';
COMMENT ON COLUMN public.workout_exercises.workout_id IS 'ID of the workout to which the exercise belongs.';
COMMENT ON COLUMN public.workout_exercises.exercise_id IS 'ID of the exercise in the workout.';
COMMENT ON COLUMN public.workout_exercises.position IS 'Position of the exercise in the workout, used for ordering.';

CREATE TABLE public.workout_result_exercise_results (
    workout_result_id UUID NOT NULL REFERENCES public.workout_results(id) ON DELETE CASCADE,
    exercise_result_id UUID NOT NULL REFERENCES public.exercise_results(id) ON DELETE CASCADE,
    position INTEGER NOT NULL,
    UNIQUE (workout_result_id, position),
    PRIMARY KEY (workout_result_id, exercise_result_id)
);

COMMENT ON TABLE public.workout_result_exercise_results IS 'Join table linking workout results and exercise results, defining the order of exercise results in a workout result.';
COMMENT ON COLUMN public.workout_result_exercise_results.workout_result_id IS 'ID of the workout result to which the exercise result belongs.';
COMMENT ON COLUMN public.workout_result_exercise_results.exercise_result_id IS 'ID of the exercise result in the workout result.';
COMMENT ON COLUMN public.workout_result_exercise_results.position IS 'Position of the exercise result in the workout result, used for ordering.';

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

CREATE OR REPLACE VIEW public.workout_exercise_options AS
SELECT
  id AS value,
  name || ' (' || LEFT(id::text, 4) || '*' || ')' AS label,
  is_locked AS disable
FROM public.exercises
WHERE user_id = auth.uid();

COMMENT ON VIEW public.workout_exercise_options IS 'View for workout exercise options used in forms.';

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

CREATE OR REPLACE FUNCTION public.inspect_workout(w_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SET search_path = ''
AS $$
DECLARE
  inspect_workout JSONB;
BEGIN
  SELECT to_jsonb(w)
    || jsonb_build_object(
      'exercises',
        (
          SELECT jsonb_agg(jsonb_build_object('id', e.id, 'name', e.name) ORDER BY we.position)
          FROM public.workout_exercises we
          JOIN public.exercises e ON e.id = we.exercise_id
          WHERE we.workout_id = w.id
        ),
      'last_workout_result',
        (
          SELECT jsonb_build_object(
            'id', wr.id,
            'created_at', wr.created_at,
            'finished_at', wr.finished_at,
            'duration_seconds', EXTRACT(EPOCH FROM (wr.finished_at - wr.created_at)),
            'note', wr.note
          )
          FROM public.workout_results wr
          WHERE wr.workout_id = w.id
          ORDER BY wr.created_at DESC
          LIMIT 1
        )
    )
  INTO inspect_workout
  FROM public.workouts w
  WHERE w.id = w_id
  AND w.user_id = auth.uid();

  RETURN inspect_workout;
END;
$$;

COMMENT ON FUNCTION public.inspect_workout(w_id UUID) IS 'Function for inspect workout dialogs.';

CREATE OR REPLACE FUNCTION public.edit_workout(w_id UUID)
RETURNS TABLE (
  id UUID,
  name TEXT,
  description TEXT,
  schedule public.workout_schedule_type[],
  is_locked BOOLEAN,
  exercises UUID[]
)
LANGUAGE sql
SET search_path = ''
AS $$
  SELECT
    w.id,
    w.name,
    w.description,
    w.schedule,
    w.is_locked,
    ARRAY(
      SELECT we.exercise_id
      FROM public.workout_exercises we
      WHERE we.workout_id = w.id
      ORDER BY we.position
    ) AS exercises
  FROM public.workouts w
  WHERE w.id = w_id
  AND w.user_id = auth.uid();
$$;

COMMENT ON FUNCTION public.edit_workout(w_id UUID) IS 'Function for edit workout dialogs.';
