--
-- SELECT public.seed_workouts_for_user('YOUR-USER-UUID');
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
BEGIN
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

  -- Insert workout_results for selected workouts
  INSERT INTO public.workout_results (user_id, workout_id, note)
    VALUES
      (p_user_id, daily_id, 'Seed result for Daily workout'),
      (p_user_id, weekly_id, 'Seed result for Weekly workout'),
      (p_user_id, mwf_id, 'Seed result for M/W/F workout'),
      (p_user_id, sunday_id, 'Seed result for Sunday workout');
END;
$$ LANGUAGE plpgsql;
