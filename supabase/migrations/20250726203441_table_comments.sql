--
-- Table Comments
--

COMMENT ON TABLE public.exercises IS 'Table for storing exercises, including their type and data.';
COMMENT ON TABLE public.workouts IS 'Table for storing workouts, including their schedule.';
COMMENT ON TABLE public.exercise_results IS 'Table for storing individual exercise results.';
COMMENT ON TABLE public.workout_results IS 'Table for storing individual workout results.';
COMMENT ON TABLE public.workout_exercises IS 'Join table linking workouts and exercises, defining the order of exercises in a workout.';
COMMENT ON TABLE public.workout_result_exercise_results IS 'Join table linking workout results and exercise results, defining the order of exercise results in a workout result.';

--
-- Enum Changes
--

ALTER TYPE public.exercise_type RENAME VALUE 'Weight' TO 'Weightlifting';
ALTER TYPE public.exercise_type RENAME VALUE 'Sided Weight' TO 'Sided Weightlifting';

--
-- Policies
--

-- Exercises
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

-- Workouts
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

-- Exercise Results
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

-- Workout Results
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

-- Workout Exercises
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

-- Workout Result Exercise Results
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
