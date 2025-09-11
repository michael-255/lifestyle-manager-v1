import { z } from 'zod'
import { textAreaSchema, textLabelSchema } from './common-schemas'

export type TodaysWorkout = Tables<'todays_workouts'> & { is_completed: boolean }
export type Workout = Database['public']['Tables']['workouts']['Row']
export type WorkoutResult = Database['public']['Tables']['workout_results']['Row']
export type WorkoutSchedule = Database['public']['Enums']['workout_schedule_type']

export const finishedAtSchema = timestampzSchema.optional()
export const workoutScheduleSchema = z.enum(Constants.public.Enums.workout_schedule_type)

export const getActiveWorkoutResponseSchema = z.object({
  workout: z.object({
    id: idSchema,
    created_at: timestampzSchema,
    name: textLabelSchema,
    description: textAreaSchema.nullable(),
    schedule: z.array(workoutScheduleSchema).nullable(),
    exercises: z
      .array(
        z.object({
          name: textLabelSchema,
          description: textAreaSchema.nullable(),
          rest_timer: z.number().min(0).nullable(),
          checklist: z.array(textLabelSchema).nullable(),
        }),
      )
      .nullable(),
    is_active: z.boolean(),
  }),
  workout_result: z.object({
    id: idSchema,
    workout_id: idSchema,
    created_at: timestampzSchema,
    finished_at: finishedAtSchema.nullable(),
    note: textAreaSchema.nullable(),
    exercise_results: z
      .array(
        z.object({
          note: textAreaSchema.nullable(),
          checked: z.array(z.boolean()).nullable(),
        }),
      )
      .nullable(),
    is_active: z.boolean(),
  }),
})

export type GetActiveWorkoutResponse = z.infer<typeof getActiveWorkoutResponseSchema>
