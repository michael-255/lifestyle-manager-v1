--
-- SQL commands to clear out all fitness tables, enums, functions, and data
--

-- Tables
DROP TABLE IF EXISTS
  public.workout_result_exercise_results,
  public.workout_exercises,
  public.workout_results,
  public.exercise_results,
  public.workouts,
  public.exercises
CASCADE;

-- Views
DROP VIEW IF EXISTS public.todays_workouts;

-- Enums
DROP TYPE IF EXISTS public.exercise_type;
DROP TYPE IF EXISTS public.workout_schedule_type;

-- Functions
DROP FUNCTION IF EXISTS public.seed_workouts_for_user(uuid);
