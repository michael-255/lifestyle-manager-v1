import {
  DialogCharts,
  DialogConfirm,
  DialogFitnessCreateExercise,
  DialogFitnessCreateWorkout,
  DialogFitnessEditExercise,
  DialogFitnessEditExerciseResult,
  DialogFitnessEditWorkout,
  DialogFitnessEditWorkoutResult,
  DialogFitnessInspectExercise,
  DialogFitnessInspectExerciseResult,
  DialogFitnessInspectWorkout,
  DialogFitnessInspectWorkoutResult,
} from '#components'
import { deleteIcon } from '#shared/constants'

export default function useFitnessDialogs() {
  const $q = useQuasar()
  const logger = useLogger()
  const supabase = useSupabaseClient<Database>()

  //
  // Exercises
  //

  async function openChartExercise(id: IdType) {
    try {
      $q.dialog({
        component: DialogCharts,
        componentProps: { id },
      })
    } catch (error) {
      logger.error('Error opening exercise chart dialog', error as Error)
    }
  }

  async function openInspectExercise(id: IdType) {
    try {
      $q.dialog({
        component: DialogFitnessInspectExercise,
        componentProps: { id },
      })
    } catch (error) {
      logger.error('Error opening exercise inspect dialog', error as Error)
    }
  }

  function openCreateExercise() {
    try {
      $q.dialog({ component: DialogFitnessCreateExercise })
    } catch (error) {
      logger.error('Error opening exercise create dialog', error as Error)
    }
  }

  async function openEditExercise(id: IdType) {
    try {
      $q.dialog({
        component: DialogFitnessEditExercise,
        componentProps: { id },
      })
    } catch (error) {
      logger.error('Error opening exercise edit dialog', error as Error)
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
      $q.dialog({
        component: DialogFitnessInspectExerciseResult,
        componentProps: { id },
      })
    } catch (error) {
      logger.error('Error opening exercise result inspect dialog', error as Error)
    }
  }

  async function openEditExerciseResult(id: IdType) {
    try {
      $q.dialog({
        component: DialogFitnessEditExerciseResult,
        componentProps: { id },
      })
    } catch (error) {
      logger.error('Error opening exercise result edit dialog', error as Error)
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

  //
  // Workouts
  //

  async function openChartWorkout(id: IdType) {
    try {
      $q.dialog({
        component: DialogCharts,
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
    // Exercises
    openChartExercise,
    openInspectExercise,
    openCreateExercise,
    openEditExercise,
    openDeleteExercise,
    // Exercise Results
    openInspectExerciseResult,
    openEditExerciseResult,
    openDeleteExerciseResult,
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
