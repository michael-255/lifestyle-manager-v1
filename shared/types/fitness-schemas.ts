import { z } from 'zod'
import { textAreaSchema, textLabelSchema } from './common-schemas'

export type TodaysWorkout = Tables<'todays_workouts'>

export type Workout = Database['public']['Tables']['workouts']['Row']
export type WorkoutResult = Database['public']['Tables']['workout_results']['Row']

export type Exercise = Database['public']['Tables']['exercises']['Row']
export type ExerciseResult = Database['public']['Tables']['exercise_results']['Row']

export type WorkoutSchedule = Database['public']['Enums']['workout_schedule_type']

export type ExerciseType = Database['public']['Enums']['exercise_type']

export const exerciseTypeSchema = z.enum(Constants.public.Enums.exercise_type)

export const finishedAtSchema = timestampzSchema.optional()
export const workoutScheduleSchema = z.enum(Constants.public.Enums.workout_schedule_type)

export const inspectWorkoutResponseSchema = z.object({
  workout: z.object({
    id: idSchema,
    user_id: idSchema,
    created_at: timestampzSchema,
    name: textLabelSchema,
    description: textAreaSchema.nullable(),
    schedule: z.array(workoutScheduleSchema).nullable(),
    is_locked: z.boolean(),
  }),
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

export type InspectWorkoutResponse = z.infer<typeof inspectWorkoutResponseSchema>

export const workoutExerciseOptionSchema = z.object({
  value: idSchema.nullable(),
  label: z.string().nullable(),
  disable: z.boolean().nullable(),
})

export type WorkoutExerciseOption = z.infer<typeof workoutExerciseOptionSchema>

export const inspectExerciseResponseSchema = z.object({
  exercise: z.object({
    id: idSchema,
    user_id: idSchema,
    created_at: timestampzSchema,
    name: textLabelSchema,
    description: textAreaSchema.nullable(),
    rest_timer: z.number().nullable(),
    type: exerciseTypeSchema,
    checklist_labels: z.array(z.string()).nullable(),
    initial_sets: z.number().nullable(),
    is_locked: z.boolean(),
  }),
  total_results: z.number().nullable(),
  workouts_used: z
    .array(
      z.object({
        id: idSchema,
        name: textLabelSchema,
      }),
    )
    .nullable(), // could be null if no workouts used
})

export type InspectExerciseResponse = z.infer<typeof inspectExerciseResponseSchema>
