import { z } from 'zod'
import { textAreaSchema, textLabelSchema } from './common-schemas'

export type TodaysWorkout = Tables<'todays_workouts'>

export type Workout = Database['public']['Tables']['workouts']['Row']
export type WorkoutResult = Database['public']['Tables']['workout_results']['Row']

export type Exercise = Database['public']['Tables']['exercises']['Row']
export type ExerciseResult = Database['public']['Tables']['exercise_results']['Row']

export type WorkoutSchedule = Database['public']['Enums']['workout_schedule_type']

export const finishedAtSchema = timestampzSchema.optional()
export const workoutScheduleSchema = z.enum(Constants.public.Enums.workout_schedule_type)

export const inspectWorkoutSchema = z.object({
  id: idSchema,
  user_id: idSchema,
  created_at: timestampzSchema,
  name: textLabelSchema,
  description: textAreaSchema.nullable(),
  schedule: z.array(workoutScheduleSchema).nullable(),
  is_locked: z.boolean(),
  exercises: z
    .array(
      z.object({
        id: idSchema,
        name: textLabelSchema,
      }),
    )
    .nullable(), // could be null if no exercises
  last_workout_result: z
    .object({
      id: idSchema,
      created_at: timestampzSchema,
      finished_at: finishedAtSchema.nullable(),
      duration_seconds: z.number().nullable(),
      note: textAreaSchema.nullable(),
    })
    .nullable(), // could be null if no previous workout results
})

export type InspectWorkout = z.infer<typeof inspectWorkoutSchema>
