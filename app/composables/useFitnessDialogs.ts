import {
  DialogConfirm,
  DialogCreate,
  DialogEdit,
  DialogFormItemCreatedDate,
  DialogFormItemDescription,
  DialogFormItemName,
  DialogFormItemSchedule,
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

      // TODO
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
      $q.dialog({
        component: DialogCreate,
        componentProps: {
          label: 'Workout',
          record: {
            created_at: new Date().toISOString(),
          },
          subComponents: [
            { component: DialogFormItemName },
            { component: DialogFormItemDescription },
            { component: DialogFormItemCreatedDate },
            { component: DialogFormItemSchedule }, // TODO - WIP
            // TODO - { component: DialogFormItemWorkoutExercises },
          ],
          onSubmitHandler: () =>
            supabase.from('workouts').insert([localRecordStore.record as Workout]),
        },
      })
    } catch (error) {
      logger.error('Error opening workout create dialog', error as Error)
    }
  }

  async function openEditWorkout(id: IdType) {
    try {
      $q.loading.show()

      // TODO
      const { data, error } = await supabase.from('workouts').select('*').eq('id', id).single()
      if (error) throw error

      $q.dialog({
        component: DialogEdit,
        componentProps: {
          label: 'Workout',
          record: data,
          subComponents: [
            { component: DialogFormItemName },
            { component: DialogFormItemDescription },
            { component: DialogFormItemCreatedDate },
            { component: DialogFormItemSchedule }, // TODO - WIP
            // TODO - { component: DialogFormItemWorkoutExercises },
          ],
          onSubmitHandler: () =>
            supabase
              .from('workouts')
              .update(localRecordStore.record as Workout)
              .eq('id', id),
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
          const { error } = await supabase.from('workouts').delete().eq('id', id)
          if (error) throw error
          logger.info('Workout deleted', { id })
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

      // TODO
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

  function openCreateWorkoutResult() {
    try {
      $q.dialog({
        component: DialogCreate,
        componentProps: {
          label: 'Workout Result',
          record: {
            created_at: new Date().toISOString(),
          },
          subComponents: [
            { component: DialogFormItemCreatedDate },
            // TODO
          ],
          onSubmitHandler: () =>
            supabase.from('workout_results').insert([localRecordStore.record as WorkoutResult]),
        },
      })
    } catch (error) {
      logger.error('Error opening workout result create dialog', error as Error)
    }
  }

  async function openEditWorkoutResult(id: IdType) {
    try {
      $q.loading.show()

      // TODO
      const { data, error } = await supabase
        .from('workout_results')
        .select('*')
        .eq('id', id)
        .single()
      if (error) throw error

      $q.dialog({
        component: DialogEdit,
        componentProps: {
          label: 'Workout Result',
          record: data,
          subComponents: [
            { component: DialogFormItemCreatedDate },
            // TODO
          ],
          onSubmitHandler: () =>
            supabase
              .from('workout_results')
              .update(localRecordStore.record as WorkoutResult)
              .eq('id', id),
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
          const { error } = await supabase.from('workout_results').delete().eq('id', id)
          if (error) throw error
          logger.info('Workout result deleted', { id })
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

      // TODO
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
      $q.dialog({
        component: DialogCreate,
        componentProps: {
          label: 'Exercise',
          record: {
            created_at: new Date().toISOString(),
          },
          subComponents: [
            { component: DialogFormItemName },
            { component: DialogFormItemDescription },
            { component: DialogFormItemCreatedDate },
            // TODO
          ],
          onSubmitHandler: () =>
            supabase.from('exercises').insert([localRecordStore.record as Exercise]),
        },
      })
    } catch (error) {
      logger.error('Error opening exercise create dialog', error as Error)
    }
  }

  async function openEditExercise(id: IdType) {
    try {
      $q.loading.show()

      // TODO
      const { data, error } = await supabase.from('exercises').select('*').eq('id', id).single()
      if (error) throw error

      $q.dialog({
        component: DialogEdit,
        componentProps: {
          label: 'Exercise',
          record: data,
          subComponents: [
            { component: DialogFormItemName },
            { component: DialogFormItemDescription },
            { component: DialogFormItemCreatedDate },
            // TODO
          ],
          onSubmitHandler: () =>
            supabase
              .from('exercises')
              .update(localRecordStore.record as Exercise)
              .eq('id', id),
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
          const { error } = await supabase.from('exercises').delete().eq('id', id)
          if (error) throw error
          logger.info('Exercise deleted', { id })
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

      // TODO
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

  function openCreateExerciseResult() {
    try {
      $q.dialog({
        component: DialogCreate,
        componentProps: {
          label: 'Exercise Result',
          record: {
            created_at: new Date().toISOString(),
          },
          subComponents: [
            { component: DialogFormItemCreatedDate },
            // TODO
          ],
          onSubmitHandler: () =>
            supabase.from('exercise_results').insert([localRecordStore.record as ExerciseResult]),
        },
      })
    } catch (error) {
      logger.error('Error opening exercise result create dialog', error as Error)
    }
  }

  async function openEditExerciseResult(id: IdType) {
    try {
      $q.loading.show()

      // TODO
      const { data, error } = await supabase
        .from('exercise_results')
        .select('*')
        .eq('id', id)
        .single()
      if (error) throw error

      $q.dialog({
        component: DialogEdit,
        componentProps: {
          label: 'Exercise Result',
          record: data,
          subComponents: [
            { component: DialogFormItemCreatedDate },
            // TODO
          ],
          onSubmitHandler: () =>
            supabase
              .from('exercise_results')
              .update(localRecordStore.record as ExerciseResult)
              .eq('id', id),
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
          const { error } = await supabase.from('exercise_results').delete().eq('id', id)
          if (error) throw error
          logger.info('Exercise result deleted', { id })
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
    openCreateWorkoutResult,
    openEditWorkoutResult,
    openDeleteWorkoutResult,
    // Exercises
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
