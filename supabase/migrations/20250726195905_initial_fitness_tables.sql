--
-- ENUMS
--

CREATE TYPE public.exercise_type AS ENUM (
    'Checklist',
    'Cardio',
    'Weight',
    'Sided Weight',
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
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    type public.exercise_type NOT NULL,
    default_sets INTEGER DEFAULT 1,
    rest_timer INTEGER,
    is_locked BOOLEAN DEFAULT FALSE
);

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
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    schedule public.workout_schedule_type[],
    is_locked BOOLEAN DEFAULT FALSE
);

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
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL,
    note TEXT,
    data JSONB, -- For all potential exercise data
    is_locked BOOLEAN DEFAULT FALSE
);

COMMENT ON COLUMN public.exercise_results.id IS 'Unique identifier for the exercise result.';
COMMENT ON COLUMN public.exercise_results.user_id IS 'ID of the user who owns the exercise result.';
COMMENT ON COLUMN public.exercise_results.exercise_id IS 'ID of the exercise for which the result is recorded.';
COMMENT ON COLUMN public.exercise_results.created_at IS 'Timestamp when the exercise result was created.';
COMMENT ON COLUMN public.exercise_results.note IS 'Optional note for the exercise result.';
COMMENT ON COLUMN public.exercise_results.data IS 'JSONB data containing all potential exercise data.';
COMMENT ON COLUMN public.exercise_results.is_locked IS 'Indicates if the exercise result is locked for editing.';

CREATE TABLE public.workout_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL,
    finished_at TIMESTAMPTZ,
    note TEXT,
    is_locked BOOLEAN DEFAULT FALSE
);

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

COMMENT ON COLUMN public.workout_result_exercise_results.workout_result_id IS 'ID of the workout result to which the exercise result belongs.';
COMMENT ON COLUMN public.workout_result_exercise_results.exercise_result_id IS 'ID of the exercise result in the workout result.';
COMMENT ON COLUMN public.workout_result_exercise_results.position IS 'Position of the exercise result in the workout result, used for ordering.';
