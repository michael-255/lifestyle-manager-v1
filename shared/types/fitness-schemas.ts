export type TodaysWorkout = Tables<'todays_workouts'>

export type Workout = Database['public']['Tables']['workouts']['Row']
export type WorkoutResult = Database['public']['Tables']['workout_results']['Row']

export type Exercise = Database['public']['Tables']['exercises']['Row']
export type ExerciseResult = Database['public']['Tables']['exercise_results']['Row']

export type WorkoutSchedule = Database['public']['Enums']['workout_schedule_type']
