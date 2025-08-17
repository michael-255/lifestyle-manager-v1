import { DialogConfirm, DialogCreate, DialogEdit, DialogInspect } from '#components'
import { deleteIcon } from '#shared/constants'

export default function useFitnessExerciseResultDialogs() {
  const $q = useQuasar()
  const logger = useLogger()
  const supabase = useSupabaseClient<Database>()
  const localRecordStore = useLocalRecordStore()

  async function openInspectExerciseResult(id: IdType) {
    try {
      $q.loading.show()

      const { data, error } = await supabase
        .from('exercise_results')
        .select('*')
        .eq('id', id)
        .single()
      if (error) throw error

      console.log('Opening exercise result inspect dialog for id:', id, data)

      $q.dialog({
        component: DialogInspect,
        componentProps: {
          label: 'Exercise Result',
          inspectComponent: {},
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
          formComponent: {},
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
          formComponent: {},
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
    openInspectExerciseResult,
    openCreateExerciseResult,
    openEditExerciseResult,
    openDeleteExerciseResult,
  }
}
