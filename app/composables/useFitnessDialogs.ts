import {
  DialogCharts,
  DialogConfirm,
  DialogCreate,
  DialogEdit,
  DialogFormItemChecklistLabels,
  DialogFormItemCreatedDate,
  DialogFormItemDescription,
  DialogFormItemExerciseType,
  DialogFormItemFinishedDate,
  DialogFormItemName,
  DialogFormItemNote,
  DialogFormItemRestTimer,
  DialogFormItemWorkoutExercises,
  DialogFormItemWorkoutSchedule,
  DialogInspect,
  DialogInspectItemBoolean,
  DialogInspectItemDate,
  DialogInspectItemList,
  DialogInspectItemObject,
  DialogInspectItemObjectList,
  DialogInspectItemText,
} from '#components'
import { deleteIcon } from '#shared/constants'
import {
  inspectExerciseSchema,
  inspectWorkoutSchema,
  type Exercise,
  type InspectExercise,
  type InspectWorkout,
  type WorkoutResult,
} from '#shared/types/fitness-schemas'

export default function useFitnessDialogs() {
  const $q = useQuasar()
  const logger = useLogger()
  const supabase = useSupabaseClient<Database>()
  const localRecordStore = useLocalRecordStore()

  //
  // Workouts
  //

  // TODO
  async function openChartWorkout(id: IdType) {
    try {
      $q.loading.show()

      console.log('Opening workout charts dialog for id:', id)

      $q.dialog({
        component: DialogCharts,
        componentProps: {
          label: 'Workout Charts',
          subComponents: [],
        },
      })
    } catch (error) {
      logger.error('Error opening workout chart dialog', error as Error)
    } finally {
      $q.loading.hide()
    }
  }

  async function openInspectWorkout(id: IdType) {
    try {
      $q.loading.show()

      const { data, error } = await supabase.rpc('inspect_workout', { w_id: id })
      if (error) throw error

      const inspect: InspectWorkout = inspectWorkoutSchema.parse(data)

      $q.dialog({
        component: DialogInspect,
        componentProps: {
          label: 'Workout',
          subComponents: [
            {
              component: DialogInspectItemText,
              props: { label: 'Id', value: inspect.workout.id },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'User Id', value: inspect.workout.user_id },
            },
            {
              component: DialogInspectItemDate,
              props: { label: 'Created At', value: inspect.workout.created_at },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'Name', value: inspect.workout.name },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'Description', value: inspect.workout.description },
            },
            {
              component: DialogInspectItemList,
              props: { label: 'Schedule', value: inspect.workout.schedule },
            },
            {
              component: DialogInspectItemObject,
              props: { label: 'Last Workout', value: inspect.last_workout_result },
            },
            {
              component: DialogInspectItemObjectList,
              props: { label: 'Exercises', value: inspect.exercises },
            },
            {
              component: DialogInspectItemBoolean,
              props: { label: 'Locked', value: inspect.workout.is_locked },
            },
          ],
        },
      })
    } catch (error) {
      logger.error('Error opening workout inspect dialog', error as Error)
    } finally {
      $q.loading.hide()
    }
  }

  function openCreateWorkout() {
    try {
      localRecordStore.record = {
        created_at: new Date().toISOString(),
      }

      $q.dialog({
        component: DialogCreate,
        componentProps: {
          label: 'Workout',
          subComponents: [
            { component: DialogFormItemName },
            { component: DialogFormItemDescription },
            { component: DialogFormItemCreatedDate },
            { component: DialogFormItemWorkoutExercises },
            { component: DialogFormItemWorkoutSchedule },
          ],
          onSubmitHandler: async () => {
            const workout = localRecordStore.getWorkout
            const workoutExercises = localRecordStore.getWorkoutExercises

            const { error } = await supabase.rpc('create_workout', {
              w_name: workout.name,
              w_description: workout.description,
              w_created_at: workout.created_at,
              w_schedule: workout.schedule,
              w_exercise_ids: workoutExercises.map((id: string) => id),
            })
            if (error) throw error

            logger.info('Workout created', { ...workout, exercises: workoutExercises })
          },
        },
      })
    } catch (error) {
      logger.error('Error opening workout create dialog', error as Error)
    }
  }

  async function openEditWorkout(id: IdType) {
    try {
      $q.loading.show()

      const { data, error } = await supabase.rpc('inspect_workout', { w_id: id })
      if (error) throw error

      const inspect: InspectWorkout = inspectWorkoutSchema.parse(data)

      localRecordStore.record = {
        ...inspect.workout,
        exercises: inspect.exercises?.map((e) => e.id) || [],
      }

      $q.dialog({
        component: DialogEdit,
        componentProps: {
          label: 'Workout',
          subComponents: [
            { component: DialogFormItemName },
            { component: DialogFormItemDescription },
            { component: DialogFormItemCreatedDate },
            { component: DialogFormItemWorkoutExercises },
            { component: DialogFormItemWorkoutSchedule },
          ],
          onSubmitHandler: async () => {
            const workout = localRecordStore.getWorkout
            const workoutExercises = localRecordStore.getWorkoutExercises

            const { error } = await supabase.rpc('edit_workout', {
              w_id: id,
              w_name: workout.name,
              w_description: workout.description,
              w_created_at: workout.created_at,
              w_schedule: workout.schedule,
              w_exercise_ids: workoutExercises.map((id: string) => id),
            })
            if (error) throw error

            logger.info('Workout updated', { ...workout, exercises: workoutExercises })
          },
        },
      })
    } catch (error) {
      logger.error('Error opening workout edit dialog', error as Error)
    } finally {
      $q.loading.hide()
    }
  }

  function openDeleteWorkout(id: IdType) {
    try {
      $q.dialog({
        component: DialogConfirm,
        componentProps: {
          title: 'Delete Workout',
          message: `Are you sure you want to delete workout "${id}"?`,
          color: 'negative',
          icon: deleteIcon,
          requiresUnlock: true,
        },
      }).onOk(async () => {
        try {
          $q.loading.show()

          const { data, error } = await supabase
            .from('workouts')
            .delete()
            .eq('id', id)
            .select()
            .single()
          if (error) throw error

          logger.info('Workout deleted', data)
        } catch (error) {
          logger.error('Error deleting workout', error as Error)
        } finally {
          $q.loading.hide()
        }
      })
    } catch (error) {
      logger.error('Error opening workout delete dialog', error as Error)
    }
  }

  //
  // Workout Results
  //

  async function openInspectWorkoutResult(id: IdType) {
    try {
      $q.loading.show()

      const { data, error } = await supabase
        .from('workout_results')
        .select('*')
        .eq('id', id)
        .single()
      if (error) throw error

      $q.dialog({
        component: DialogInspect,
        componentProps: {
          label: 'Workout Result',
          subComponents: [
            {
              component: DialogInspectItemText,
              props: { label: 'Id', value: data.id },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'User Id', value: data.user_id },
            },
            {
              component: DialogInspectItemDate,
              props: { label: 'Created At', value: data.created_at },
            },
            {
              component: DialogInspectItemDate,
              props: { label: 'Finished At', value: data.finished_at },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'Workout Id', value: data.workout_id },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'Notes', value: data.note },
            },
            {
              component: DialogInspectItemBoolean,
              props: { label: 'Locked', value: data.is_locked },
            },
          ],
        },
      })
    } catch (error) {
      logger.error('Error opening workout result inspect dialog', error as Error)
    } finally {
      $q.loading.hide()
    }
  }

  async function openCreateWorkoutResult() {
    try {
      localRecordStore.record = {
        created_at: new Date().toISOString(),
        finished_at: new Date().toISOString(),
      } as WorkoutResult

      $q.dialog({
        component: DialogCreate,
        componentProps: {
          label: 'Workout Result',
          subComponents: [],
          onSubmitHandler: async () => {
            const { data, error } = await supabase
              .from('workout_results')
              .insert([localRecordStore.record as WorkoutResult])
              .select()
              .single()
            if (error) throw error

            logger.info('Workout result created', data)
          },
        },
      })
    } catch (error) {
      logger.error('Error opening workout result create dialog', error as Error)
    }
  }

  async function openEditWorkoutResult(id: IdType) {
    try {
      $q.loading.show()

      const { data, error } = await supabase
        .from('workout_results')
        .select('*')
        .eq('id', id)
        .single()
      if (error) throw error

      localRecordStore.record = data as WorkoutResult

      $q.dialog({
        component: DialogEdit,
        componentProps: {
          label: 'Workout Result',
          subComponents: [
            { component: DialogFormItemCreatedDate },
            { component: DialogFormItemFinishedDate },
            { component: DialogFormItemNote },
          ],
          onSubmitHandler: async () => {
            const { data, error } = await supabase
              .from('workout_results')
              .update(localRecordStore.record as WorkoutResult)
              .eq('id', id)
              .select()
              .single()
            if (error) throw error

            logger.info('Workout result updated', data)
          },
        },
      })
    } catch (error) {
      logger.error('Error opening workout result edit dialog', error as Error)
    } finally {
      $q.loading.hide()
    }
  }

  function openDeleteWorkoutResult(id: IdType) {
    try {
      $q.dialog({
        component: DialogConfirm,
        componentProps: {
          title: 'Delete Workout Result',
          message: `Are you sure you want to delete workout result "${id}"?`,
          color: 'negative',
          icon: deleteIcon,
          requiresUnlock: true,
        },
      }).onOk(async () => {
        try {
          $q.loading.show()

          const { data, error } = await supabase
            .from('workout_results')
            .delete()
            .eq('id', id)
            .select()
            .single()
          if (error) throw error

          logger.info('Workout result deleted', data)
        } catch (error) {
          logger.error('Error deleting workout result', error as Error)
        } finally {
          $q.loading.hide()
        }
      })
    } catch (error) {
      logger.error('Error opening workout result delete dialog', error as Error)
    }
  }

  //
  // Exercises
  //

  // TODO
  async function openChartExercise(id: IdType) {
    try {
      $q.loading.show()

      console.log('Opening exercise charts dialog for id:', id)

      $q.dialog({
        component: DialogCharts,
        componentProps: {
          label: 'Exercise Charts',
          subComponents: [],
        },
      })
    } catch (error) {
      logger.error('Error opening exercise chart dialog', error as Error)
    } finally {
      $q.loading.hide()
    }
  }

  async function openInspectExercise(id: IdType) {
    try {
      $q.loading.show()

      const { data, error } = await supabase.rpc('inspect_exercise', { e_id: id })
      if (error) throw error

      console.log('Inspect exercise data:', data)

      const inspect: InspectExercise = inspectExerciseSchema.parse(data)

      $q.dialog({
        component: DialogInspect,
        componentProps: {
          label: 'Exercise',
          subComponents: [
            {
              component: DialogInspectItemText,
              props: { label: 'Id', value: inspect.exercise.id },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'User Id', value: inspect.exercise.user_id },
            },
            {
              component: DialogInspectItemDate,
              props: { label: 'Created At', value: inspect.exercise.created_at },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'Name', value: inspect.exercise.name },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'Description', value: inspect.exercise.description },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'Type', value: inspect.exercise.type },
            },
            {
              component: DialogInspectItemList,
              props: { label: 'Checklist Labels', value: inspect.exercise.checklist_labels },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'Initial Sets', value: inspect.exercise.initial_sets },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'Total Results', value: inspect.total_results },
            },
            {
              component: DialogInspectItemObjectList,
              props: { label: 'Workouts Used', value: inspect.workouts_used },
            },
            {
              component: DialogInspectItemBoolean,
              props: { label: 'Locked', value: inspect.exercise.is_locked },
            },
          ],
        },
      })
    } catch (error) {
      logger.error('Error opening exercise inspect dialog', error as Error)
    } finally {
      $q.loading.hide()
    }
  }

  function openCreateExercise() {
    try {
      localRecordStore.record = {
        created_at: new Date().toISOString(),
      } as Exercise

      $q.dialog({
        component: DialogCreate,
        componentProps: {
          label: 'Exercise',
          subComponents: [
            { component: DialogFormItemName },
            { component: DialogFormItemDescription },
            { component: DialogFormItemCreatedDate },
            { component: DialogFormItemRestTimer },
            { component: DialogFormItemExerciseType },
            { component: DialogFormItemChecklistLabels },
            // TODO
          ],
          onSubmitHandler: async () => {
            const { data, error } = await supabase
              .from('exercises')
              .insert([localRecordStore.record as Exercise])
              .select()
              .single()
            if (error) throw error

            logger.info('Exercise created', data)
          },
        },
      })
    } catch (error) {
      logger.error('Error opening exercise create dialog', error as Error)
    }
  }

  async function openEditExercise(id: IdType) {
    try {
      $q.loading.show()

      const { data, error } = await supabase.from('exercises').select('*').eq('id', id).single()
      if (error) throw error

      localRecordStore.record = data as Exercise

      $q.dialog({
        component: DialogEdit,
        componentProps: {
          label: 'Exercise',
          subComponents: [
            { component: DialogFormItemName },
            { component: DialogFormItemDescription },
            { component: DialogFormItemCreatedDate },
            // TODO
          ],
          onSubmitHandler: async () => {
            const { data, error } = await supabase
              .from('exercises')
              .update(localRecordStore.record as Exercise)
              .eq('id', id)
              .select()
              .single()
            if (error) throw error

            logger.info('Exercise updated', data)
          },
        },
      })
    } catch (error) {
      logger.error('Error opening exercise edit dialog', error as Error)
    } finally {
      $q.loading.hide()
    }
  }

  function openDeleteExercise(id: IdType) {
    try {
      $q.dialog({
        component: DialogConfirm,
        componentProps: {
          title: 'Delete Exercise',
          message: `Are you sure you want to delete exercise "${id}"?`,
          color: 'negative',
          icon: deleteIcon,
          requiresUnlock: true,
        },
      }).onOk(async () => {
        try {
          $q.loading.show()

          const { data, error } = await supabase
            .from('exercises')
            .delete()
            .eq('id', id)
            .select()
            .single()
          if (error) throw error

          logger.info('Exercise deleted', data)
        } catch (error) {
          logger.error('Error deleting exercise', error as Error)
        } finally {
          $q.loading.hide()
        }
      })
    } catch (error) {
      logger.error('Error opening exercise delete dialog', error as Error)
    }
  }

  //
  // Exercise Results
  //

  async function openInspectExerciseResult(id: IdType) {
    try {
      $q.loading.show()

      const { data, error } = await supabase
        .from('exercise_results')
        .select('*')
        .eq('id', id)
        .single()
      if (error) throw error

      $q.dialog({
        component: DialogInspect,
        componentProps: {
          label: 'Exercise Result',
          subComponents: [
            {
              component: DialogInspectItemText,
              props: { label: 'Id', value: data.id },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'User Id', value: data.user_id },
            },
            {
              component: DialogInspectItemDate,
              props: { label: 'Created At', value: data.created_at },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'Exercise Id', value: data.exercise_id },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'Notes', value: data.note },
            },
            // TODO
          ],
        },
      })
    } catch (error) {
      logger.error('Error opening exercise result inspect dialog', error as Error)
    } finally {
      $q.loading.hide()
    }
  }

  async function openCreateExerciseResult() {
    try {
      localRecordStore.record = {
        created_at: new Date().toISOString(),
      } as ExerciseResult

      $q.dialog({
        component: DialogCreate,
        componentProps: {
          label: 'Exercise Result',
          subComponents: [
            { component: DialogFormItemCreatedDate },
            { component: DialogFormItemNote },
            // TODO
          ],
          onSubmitHandler: async () => {
            const { data, error } = await supabase
              .from('exercise_results')
              .insert([localRecordStore.record as ExerciseResult])
              .select()
              .single()
            if (error) throw error

            logger.info('Exercise result created', data)
          },
        },
      })
    } catch (error) {
      logger.error('Error opening exercise result create dialog', error as Error)
    }
  }

  async function openEditExerciseResult(id: IdType) {
    try {
      $q.loading.show()

      const { data, error } = await supabase
        .from('exercise_results')
        .select('*')
        .eq('id', id)
        .single()
      if (error) throw error

      localRecordStore.record = data as ExerciseResult

      $q.dialog({
        component: DialogEdit,
        componentProps: {
          label: 'Exercise Result',
          record: data,
          subComponents: [
            { component: DialogFormItemCreatedDate },
            // TODO
          ],
          onSubmitHandler: async () => {
            const { data, error } = await supabase
              .from('exercise_results')
              .update(localRecordStore.record as ExerciseResult)
              .eq('id', id)
              .select()
              .single()
            if (error) throw error

            logger.info('Exercise result updated', data)
          },
        },
      })
    } catch (error) {
      logger.error('Error opening exercise result edit dialog', error as Error)
    } finally {
      $q.loading.hide()
    }
  }

  function openDeleteExerciseResult(id: IdType) {
    try {
      $q.dialog({
        component: DialogConfirm,
        componentProps: {
          title: 'Delete Exercise Result',
          message: `Are you sure you want to delete exercise result "${id}"?`,
          color: 'negative',
          icon: deleteIcon,
          requiresUnlock: true,
        },
      }).onOk(async () => {
        try {
          $q.loading.show()

          const { data, error } = await supabase
            .from('exercise_results')
            .delete()
            .eq('id', id)
            .select()
            .single()
          if (error) throw error

          logger.info('Exercise result deleted', data)
        } catch (error) {
          logger.error('Error deleting exercise result', error as Error)
        } finally {
          $q.loading.hide()
        }
      })
    } catch (error) {
      logger.error('Error opening exercise result delete dialog', error as Error)
    }
  }

  return {
    // Workouts
    openChartWorkout,
    openInspectWorkout,
    openCreateWorkout,
    openEditWorkout,
    openDeleteWorkout,
    // Workout Results
    openInspectWorkoutResult,
    openCreateWorkoutResult,
    openEditWorkoutResult,
    openDeleteWorkoutResult,
    // Exercises
    openChartExercise,
    openInspectExercise,
    openCreateExercise,
    openEditExercise,
    openDeleteExercise,
    // Exercise Results
    openInspectExerciseResult,
    openCreateExerciseResult,
    openEditExerciseResult,
    openDeleteExerciseResult,
  }
}
