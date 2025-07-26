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

-- Enums
DROP TYPE IF EXISTS public.exercise_type;
DROP TYPE IF EXISTS public.workout_schedule_type;
