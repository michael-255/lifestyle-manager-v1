import {
  DialogCharts,
  DialogConfirm,
  DialogCreate,
  DialogEdit,
  DialogFormFitnessExercise,
  DialogInspect,
  DialogInspectFitnessExercise,
} from '#components'
import { deleteIcon } from '#shared/constants'
import {
  inspectExerciseSchema,
  type Exercise,
  type InspectExercise,
} from '#shared/types/fitness-schemas'

export default function useFitnessExerciseDialogs() {
  const $q = useQuasar()
  const logger = useLogger()
  const supabase = useSupabaseClient<Database>()
  const localRecordStore = useLocalRecordStore()

  // TODO
  async function openChartExercise(id: IdType) {
    try {
      $q.loading.show()

      console.log('Opening exercise charts dialog for id:', id)

      $q.dialog({
        component: DialogCharts,
        componentProps: {
          label: 'Exercise Charts',
          chartComponent: {},
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

      const inspect: InspectExercise = inspectExerciseSchema.parse(data)

      $q.dialog({
        component: DialogInspect,
        componentProps: {
          label: 'Exercise',
          inspectComponent: {
            component: DialogInspectFitnessExercise,
            props: {
              exercise: inspect.exercise,
              totalResults: inspect.total_results,
              workoutsUsed: inspect.workouts_used,
            },
          },
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
          formComponent: { component: DialogFormFitnessExercise },
          onSubmitHandler: async () => {
            // TODO: create_exercise RPC
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

      const { data, error } = await supabase.rpc('inspect_exercise', { e_id: id })
      if (error) throw error

      const inspect: InspectExercise = inspectExerciseSchema.parse(data)

      localRecordStore.record = inspect.exercise

      $q.dialog({
        component: DialogEdit,
        componentProps: {
          label: 'Exercise',
          formComponent: { component: DialogFormFitnessExercise },
          onSubmitHandler: async () => {
            // TODO: edit_exercise RPC
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

  return {
    openChartExercise,
    openInspectExercise,
    openCreateExercise,
    openEditExercise,
    openDeleteExercise,
  }
}
