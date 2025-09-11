import {
  DialogConfirm,
  DialogFitnessChartWorkout,
  DialogFitnessCreateWorkout,
  DialogFitnessEditWorkout,
  DialogFitnessEditWorkoutResult,
  DialogFitnessInspectWorkout,
  DialogFitnessInspectWorkoutResult,
} from '#components'
import { deleteIcon } from '#shared/constants'

export default function useFitnessDialogs() {
  const $q = useQuasar()
  const logger = useLogger()
  const supabase = useSupabaseClient<Database>()

  //
  // Workouts
  //

  async function openChartWorkout(id: IdType) {
    try {
      $q.dialog({
        component: DialogFitnessChartWorkout,
        componentProps: { id },
      })
    } catch (error) {
      logger.error('Error opening workout chart dialog', error as Error)
    }
  }

  async function openInspectWorkout(id: IdType) {
    try {
      $q.dialog({
        component: DialogFitnessInspectWorkout,
        componentProps: { id },
      })
    } catch (error) {
      logger.error('Error opening workout inspect dialog', error as Error)
    }
  }

  function openCreateWorkout() {
    try {
      $q.dialog({ component: DialogFitnessCreateWorkout })
    } catch (error) {
      logger.error('Error opening workout create dialog', error as Error)
    }
  }

  async function openEditWorkout(id: IdType) {
    try {
      $q.dialog({
        component: DialogFitnessEditWorkout,
        componentProps: { id },
      })
    } catch (error) {
      logger.error('Error opening workout edit dialog', error as Error)
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
      $q.dialog({
        component: DialogFitnessInspectWorkoutResult,
        componentProps: { id },
      })
    } catch (error) {
      logger.error('Error opening workout result inspect dialog', error as Error)
    }
  }

  async function openEditWorkoutResult(id: IdType) {
    try {
      $q.dialog({
        component: DialogFitnessEditWorkoutResult,
        componentProps: { id },
      })
    } catch (error) {
      logger.error('Error opening workout result edit dialog', error as Error)
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
    // Workouts
    openChartWorkout,
    openInspectWorkout,
    openCreateWorkout,
    openEditWorkout,
    openDeleteWorkout,
    // Workout Results
    openInspectWorkoutResult,
    openEditWorkoutResult,
    openDeleteWorkoutResult,
  }
}
