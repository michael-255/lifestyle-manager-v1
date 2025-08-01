import {
  DialogConfirm,
  DialogCreate,
  DialogEdit,
  DialogFormItemCreatedDate,
  DialogFormItemDescription,
  DialogFormItemName,
  DialogFormItemSchedule,
  DialogFormItemWorkoutExercises,
  DialogInspect,
  DialogInspectItemBoolean,
  DialogInspectItemDate,
  DialogInspectItemList,
  DialogInspectItemText,
} from '#components'
import { deleteIcon } from '#shared/constants'
import type { Exercise, WorkoutResult } from '~~/shared/types/fitness-schemas'

export default function useFitnessDialogs() {
  const $q = useQuasar()
  const logger = useLogger()
  const supabase = useSupabaseClient<Database>()
  const localRecordStore = useLocalRecordStore()

  //
  // Workouts
  //

  async function openInspectWorkout(id: IdType) {
    try {
      $q.loading.show()

      const { data, error } = await supabase.from('workouts').select('*').eq('id', id).single()
      if (error) throw error

      $q.dialog({
        component: DialogInspect,
        componentProps: {
          label: 'Workout',
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
              props: { label: 'Name', value: data.name },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'Description', value: data.description },
            },
            {
              component: DialogInspectItemList,
              props: { label: 'Schedule', value: data.schedule },
            },
            {
              component: DialogInspectItemBoolean,
              props: { label: 'Locked', value: data.is_locked },
            },
            // TODO - Exercises
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
      } as Workout

      $q.dialog({
        component: DialogCreate,
        componentProps: {
          label: 'Workout',
          subComponents: [
            { component: DialogFormItemName },
            { component: DialogFormItemDescription },
            { component: DialogFormItemCreatedDate },
            { component: DialogFormItemWorkoutExercises },
            { component: DialogFormItemSchedule },
          ],
          onSubmitHandler: async () => {
            const { data, error } = await supabase
              .from('workouts')
              .insert([localRecordStore.record as Workout])
              .select()
              .single()
            if (error) throw error

            localRecordStore.$reset()

            return data
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

      const { data, error } = await supabase.from('workouts').select('*').eq('id', id).single()
      if (error) throw error

      localRecordStore.record = data as Workout

      $q.dialog({
        component: DialogEdit,
        componentProps: {
          label: 'Workout',
          subComponents: [
            { component: DialogFormItemName },
            { component: DialogFormItemDescription },
            { component: DialogFormItemCreatedDate },
            { component: DialogFormItemWorkoutExercises },
            { component: DialogFormItemSchedule },
          ],
          onSubmitHandler: async () => {
            const { data, error } = await supabase
              .from('workouts')
              .update(localRecordStore.record as Workout)
              .eq('id', id)
              .select()
              .single()
            if (error) throw error

            localRecordStore.$reset()

            return data
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
            // TODO
          ],
          onSubmitHandler: async () => {
            const { data, error } = await supabase
              .from('workout_results')
              .update(localRecordStore.record as WorkoutResult)
              .eq('id', id)
              .select()
              .single()
            if (error) throw error

            localRecordStore.$reset()

            return data
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

  async function openInspectExercise(id: IdType) {
    try {
      $q.loading.show()

      const { data, error } = await supabase.from('exercises').select('*').eq('id', id).single()
      if (error) throw error

      $q.dialog({
        component: DialogInspect,
        componentProps: {
          label: 'Exercise',
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
              props: { label: 'Name', value: data.name },
            },
            {
              component: DialogInspectItemText,
              props: { label: 'Description', value: data.description },
            },
            // TODO
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
            // TODO
          ],
          onSubmitHandler: async () => {
            const { data, error } = await supabase
              .from('exercises')
              .insert([localRecordStore.record as Exercise])
              .select()
              .single()
            if (error) throw error

            localRecordStore.$reset()

            return data
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

            localRecordStore.$reset()

            return data
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

            localRecordStore.$reset()

            return data
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
    openInspectWorkout,
    openCreateWorkout,
    openEditWorkout,
    openDeleteWorkout,
    // Workout Results
    openInspectWorkoutResult,
    openEditWorkoutResult,
    openDeleteWorkoutResult,
    // Exercises
    openInspectExercise,
    openCreateExercise,
    openEditExercise,
    openDeleteExercise,
    // Exercise Results
    openInspectExerciseResult,
    openEditExerciseResult,
    openDeleteExerciseResult,
  }
}
