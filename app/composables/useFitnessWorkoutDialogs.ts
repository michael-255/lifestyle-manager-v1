import {
  DialogCharts,
  DialogConfirm,
  DialogCreate,
  DialogEdit,
  DialogFormFitnessWorkout,
  DialogInspect,
  DialogInspectFitnessWorkout,
} from '#components'
import { deleteIcon } from '#shared/constants'
import { inspectWorkoutSchema, type InspectWorkout } from '#shared/types/fitness-schemas'

export default function useFitnessWorkoutDialogs() {
  const $q = useQuasar()
  const logger = useLogger()
  const supabase = useSupabaseClient<Database>()
  const localRecordStore = useLocalRecordStore()

  // TODO
  async function openChartWorkout(id: IdType) {
    try {
      $q.loading.show()

      console.log('Opening workout charts dialog for id:', id)

      $q.dialog({
        component: DialogCharts,
        componentProps: {
          label: 'Workout Charts',
          chartComponent: {},
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
          inspectComponent: {
            component: DialogInspectFitnessWorkout,
            props: {
              workout: inspect.workout,
              exercises: inspect.exercises,
              lastWorkoutResult: inspect.last_workout_result,
            },
          },
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
          formComponent: { component: DialogFormFitnessWorkout },
          onSubmitHandler: async () => {
            const { error } = await supabase.rpc('create_workout', {
              w_name: localRecordStore.record.name,
              w_description: localRecordStore.record.description,
              w_created_at: localRecordStore.record.created_at,
              w_schedule: localRecordStore.record.schedule,
              w_exercise_ids: localRecordStore.record.exercises.map((id: string) => id),
            })
            if (error) throw error

            logger.info('Workout created', { name: localRecordStore.record.name })
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
          formComponent: { component: DialogFormFitnessWorkout },
          onSubmitHandler: async () => {
            const { error } = await supabase.rpc('edit_workout', {
              w_id: id,
              w_name: localRecordStore.record.workout.name,
              w_description: localRecordStore.record.workout.description,
              w_created_at: localRecordStore.record.workout.created_at,
              w_schedule: localRecordStore.record.workout.schedule,
              w_exercise_ids: localRecordStore.record.exercises.map((id: string) => id),
            })
            if (error) throw error

            logger.info('Workout updated', { id: localRecordStore.record.id })
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

  return {
    openChartWorkout,
    openInspectWorkout,
    openCreateWorkout,
    openEditWorkout,
    openDeleteWorkout,
  }
}
