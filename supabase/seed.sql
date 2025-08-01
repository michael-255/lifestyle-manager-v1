--
-- SELECT public.seed_workouts_for_user('USER_UUID');
--
CREATE FUNCTION public.seed_workouts_for_user(p_user_id UUID)
RETURNS void
SECURITY DEFINER
SET search_path = '' -- Should always include so you must use fully qualified schema names
AS $$
DECLARE
  daily_id UUID;
  weekly_id UUID;
  mwf_id UUID;
  sunday_id UUID;
  ex1_id UUID;
  ex2_id UUID;
  ex3_id UUID;
  ex4_id UUID;
  ex5_id UUID;
  daily_result_id UUID;
  ex1_result_id UUID;
  ex2_result_id UUID;
  ex3_result_id UUID;
  ex4_result_id UUID;
  ex5_result_id UUID;
BEGIN
  -- Insert exercises (one per statement to avoid multi-row RETURNING error)
  INSERT INTO public.exercises (user_id, name, description, type, default_sets)
    VALUES (p_user_id, 'Push Ups', 'Standard push ups.', 'Checklist', 3)
    RETURNING id INTO ex1_id;
  INSERT INTO public.exercises (user_id, name, description, type, default_sets)
    VALUES (p_user_id, 'Running', 'Morning run.', 'Cardio', 1)
    RETURNING id INTO ex2_id;
  INSERT INTO public.exercises (user_id, name, description, type, default_sets)
    VALUES (p_user_id, 'Squats', 'Bodyweight squats.', 'Checklist', 3)
    RETURNING id INTO ex3_id;
  INSERT INTO public.exercises (user_id, name, description, type, default_sets)
    VALUES (p_user_id, 'Dumbbell Curl', 'Bicep curls.', 'Weightlifting', 3)
    RETURNING id INTO ex4_id;
  INSERT INTO public.exercises (user_id, name, description, type, default_sets)
    VALUES (p_user_id, 'Plank', 'Core plank hold.', 'Checklist', 1)
    RETURNING id INTO ex5_id;

  -- Single schedule workouts
  INSERT INTO public.workouts (user_id, name, description, schedule)
    VALUES
      (p_user_id, 'Full Body Daily', 'A daily full body routine.', ARRAY['Daily']::public.workout_schedule_type[])
    RETURNING id INTO daily_id;

  INSERT INTO public.workouts (user_id, name, description, schedule)
    VALUES
      (p_user_id, 'Weekly Strength', 'A weekly strength workout.', ARRAY['Weekly']::public.workout_schedule_type[])
    RETURNING id INTO weekly_id;

  INSERT INTO public.workouts (user_id, name, description, schedule)
    VALUES
      (p_user_id, 'Sunday Cardio', 'Cardio every Sunday.', ARRAY['Sunday']::public.workout_schedule_type[])
    RETURNING id INTO sunday_id;

  -- Multi-day schedule workouts
  INSERT INTO public.workouts (user_id, name, description, schedule)
    VALUES
      (p_user_id, 'Alternate Days', 'Workout on Monday, Wednesday, Friday.', ARRAY['Monday', 'Wednesday', 'Friday']::public.workout_schedule_type[])
    RETURNING id INTO mwf_id;

  -- The rest of your workouts (not needing results)
  INSERT INTO public.workouts (user_id, name, description, schedule) VALUES
    (p_user_id, 'Monday Mobility', 'Mobility work on Mondays.', ARRAY['Monday']::public.workout_schedule_type[]),
    (p_user_id, 'Tuesday HIIT', 'High intensity interval training on Tuesdays.', ARRAY['Tuesday']::public.workout_schedule_type[]),
    (p_user_id, 'Wednesday Yoga', 'Yoga session every Wednesday.', ARRAY['Wednesday']::public.workout_schedule_type[]),
    (p_user_id, 'Thursday Core', 'Core workout on Thursdays.', ARRAY['Thursday']::public.workout_schedule_type[]),
    (p_user_id, 'Friday Upper Body', 'Upper body focus on Fridays.', ARRAY['Friday']::public.workout_schedule_type[]),
    (p_user_id, 'Saturday Long Run', 'Long run every Saturday.', ARRAY['Saturday']::public.workout_schedule_type[]),
    (p_user_id, 'Push Days', 'Push workout on Monday and Thursday.', ARRAY['Monday', 'Thursday']::public.workout_schedule_type[]),
    (p_user_id, 'Pull Days', 'Pull workout on Tuesday and Friday.', ARRAY['Tuesday', 'Friday']::public.workout_schedule_type[]),
    (p_user_id, 'Weekend Warrior', 'Special workout on Saturday and Sunday.', ARRAY['Saturday', 'Sunday']::public.workout_schedule_type[]),
    (p_user_id, 'Midweek Mix', 'Workout on Wednesday and Thursday.', ARRAY['Wednesday', 'Thursday']::public.workout_schedule_type[]);

  -- Link exercises to daily workout
  INSERT INTO public.workout_exercises (workout_id, exercise_id, position)
    VALUES
      (daily_id, ex1_id, 1),
      (daily_id, ex2_id, 2),
      (daily_id, ex3_id, 3),
      (daily_id, ex4_id, 4),
      (daily_id, ex5_id, 5);

  -- Insert workout_result for daily workout
  INSERT INTO public.workout_results (user_id, workout_id, note)
    VALUES (p_user_id, daily_id, 'Seed result for Daily workout')
    RETURNING id INTO daily_result_id;

  -- Insert exercise_results for each exercise (one per statement)
  INSERT INTO public.exercise_results (user_id, exercise_id, note, data)
    VALUES (p_user_id, ex1_id, 'Push Ups result', '{"reps": 20}')
    RETURNING id INTO ex1_result_id;
  INSERT INTO public.exercise_results (user_id, exercise_id, note, data)
    VALUES (p_user_id, ex2_id, 'Running result', '{"distance_km": 5}')
    RETURNING id INTO ex2_result_id;
  INSERT INTO public.exercise_results (user_id, exercise_id, note, data)
    VALUES (p_user_id, ex3_id, 'Squats result', '{"reps": 30}')
    RETURNING id INTO ex3_result_id;
  INSERT INTO public.exercise_results (user_id, exercise_id, note, data)
    VALUES (p_user_id, ex4_id, 'Dumbbell Curl result', '{"reps": 15, "weight_kg": 10}')
    RETURNING id INTO ex4_result_id;
  INSERT INTO public.exercise_results (user_id, exercise_id, note, data)
    VALUES (p_user_id, ex5_id, 'Plank result', '{"seconds": 60}')
    RETURNING id INTO ex5_result_id;

  -- Link exercise_results to workout_result
  INSERT INTO public.workout_result_exercise_results (workout_result_id, exercise_result_id, position)
    VALUES
      (daily_result_id, ex1_result_id, 1),
      (daily_result_id, ex2_result_id, 2),
      (daily_result_id, ex3_result_id, 3),
      (daily_result_id, ex4_result_id, 4),
      (daily_result_id, ex5_result_id, 5);

  -- Insert workout_results for selected workouts
  INSERT INTO public.workout_results (user_id, workout_id, note)
    VALUES
      (p_user_id, daily_id, 'Seed result for Daily workout'),
      (p_user_id, weekly_id, 'Seed result for Weekly workout'),
      (p_user_id, mwf_id, 'Seed result for M/W/F workout'),
      (p_user_id, sunday_id, 'Seed result for Sunday workout');
END;
$$ LANGUAGE plpgsql;
