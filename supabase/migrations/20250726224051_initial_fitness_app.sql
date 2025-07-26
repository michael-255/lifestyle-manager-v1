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
    user_id UUID NOT NULL DEFAULT (auth.uid()) REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    name TEXT NOT NULL,
    description TEXT,
    type public.exercise_type NOT NULL,
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
COMMENT ON COLUMN public.exercises.default_sets IS 'Default number of sets for the exercise (if any).';
COMMENT ON COLUMN public.exercises.rest_timer IS 'Rest timer duration in seconds (if any).';
COMMENT ON COLUMN public.exercises.is_locked IS 'Indicates if the exercise is locked for editing.';

CREATE TABLE public.workouts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL DEFAULT (auth.uid()) REFERENCES auth.users(id) ON DELETE CASCADE,
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

--
-- Result Tables
--

CREATE TABLE public.exercise_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL DEFAULT (auth.uid()) REFERENCES auth.users(id) ON DELETE CASCADE,
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
    user_id UUID NOT NULL DEFAULT (auth.uid()) REFERENCES auth.users(id) ON DELETE CASCADE,
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
-- Policies
--

-- exercises
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can select exercises"
ON public.exercises
FOR SELECT
TO authenticated
USING (user_id = (select auth.uid()));

CREATE POLICY "Authenticated users can insert exercises"
ON public.exercises
FOR INSERT
TO authenticated
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated users can update exercises"
ON public.exercises
FOR UPDATE
TO authenticated
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated users can delete exercises"
ON public.exercises
FOR DELETE
TO authenticated
USING (user_id = (select auth.uid()));

-- workouts
ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can select workouts"
ON public.workouts
FOR SELECT
TO authenticated
USING (user_id = (select auth.uid()));

CREATE POLICY "Authenticated users can insert workouts"
ON public.workouts
FOR INSERT
TO authenticated
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated users can update workouts"
ON public.workouts
FOR UPDATE
TO authenticated
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated users can delete workouts"
ON public.workouts
FOR DELETE
TO authenticated
USING (user_id = (select auth.uid()));

-- exercise_results
ALTER TABLE public.exercise_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can select"
ON public.exercise_results
FOR SELECT
TO authenticated
USING (user_id = (select auth.uid()));

CREATE POLICY "Authenticated users can insert"
ON public.exercise_results
FOR INSERT
TO authenticated
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated users can update"
ON public.exercise_results
FOR UPDATE
TO authenticated
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated users can delete"
ON public.exercise_results
FOR DELETE
TO authenticated
USING (user_id = (select auth.uid()));

-- workout_results
ALTER TABLE public.workout_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can select"
ON public.workout_results
FOR SELECT
TO authenticated
USING (user_id = (select auth.uid()));

CREATE POLICY "Authenticated users can insert"
ON public.workout_results
FOR INSERT
TO authenticated
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated users can update"
ON public.workout_results
FOR UPDATE
TO authenticated
WITH CHECK (user_id = (select auth.uid()));

CREATE POLICY "Authenticated users can delete"
ON public.workout_results
FOR DELETE
TO authenticated
USING (user_id = (select auth.uid()));

-- workout_exercises
ALTER TABLE public.workout_exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can select"
ON public.workout_exercises
FOR SELECT
TO authenticated
USING (workout_id IN (SELECT id FROM public.workouts WHERE user_id = (select auth.uid())));

CREATE POLICY "Authenticated users can insert"
ON public.workout_exercises
FOR INSERT
TO authenticated
WITH CHECK (workout_id IN (SELECT id FROM public.workouts WHERE user_id = (select auth.uid())));

CREATE POLICY "Authenticated users can update"
ON public.workout_exercises
FOR UPDATE
TO authenticated
WITH CHECK (workout_id IN (SELECT id FROM public.workouts WHERE user_id = (select auth.uid())));

CREATE POLICY "Authenticated users can delete"
ON public.workout_exercises
FOR DELETE
TO authenticated
USING (workout_id IN (SELECT id FROM public.workouts WHERE user_id = (select auth.uid())));

-- workout_result_exercise_results
ALTER TABLE public.workout_result_exercise_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can select"
ON public.workout_result_exercise_results
FOR SELECT
TO authenticated
USING (workout_result_id IN (SELECT id FROM public.workout_results WHERE user_id = (select auth.uid())));

CREATE POLICY "Authenticated users can insert"
ON public.workout_result_exercise_results
FOR INSERT
TO authenticated
WITH CHECK (workout_result_id IN (SELECT id FROM public.workout_results WHERE user_id = (select auth.uid())));

CREATE POLICY "Authenticated users can update"
ON public.workout_result_exercise_results
FOR UPDATE
TO authenticated
WITH CHECK (workout_result_id IN (SELECT id FROM public.workout_results WHERE user_id = (select auth.uid())));

CREATE POLICY "Authenticated users can delete"
ON public.workout_result_exercise_results
FOR DELETE
TO authenticated
USING (workout_result_id IN (SELECT id FROM public.workout_results WHERE user_id = (select auth.uid())));
