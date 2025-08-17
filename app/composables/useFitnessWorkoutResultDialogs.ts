import { DialogConfirm, DialogCreate, DialogEdit, DialogInspect } from '#components'
import { deleteIcon } from '#shared/constants'
import type { WorkoutResult } from '#shared/types/fitness-schemas'

export default function useFitnessWorkoutResultDialogs() {
  const $q = useQuasar()
  const logger = useLogger()
  const supabase = useSupabaseClient<Database>()
  const localRecordStore = useLocalRecordStore()

  async function openInspectWorkoutResult(id: IdType) {
    try {
      $q.loading.show()

      const { data, error } = await supabase
        .from('workout_results')
        .select('*')
        .eq('id', id)
        .single()
      if (error) throw error

      console.log('Inspecting workout result:', data)

      $q.dialog({
        component: DialogInspect,
        componentProps: {
          label: 'Workout Result',
          inspectComponent: {},
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
          formComponent: {},
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
          formComponent: {},
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

  return {
    openInspectWorkoutResult,
    openCreateWorkoutResult,
    openEditWorkoutResult,
    openDeleteWorkoutResult,
  }
}
