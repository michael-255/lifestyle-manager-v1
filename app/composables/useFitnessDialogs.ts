import {
  DialogConfirm,
  DialogCreate,
  DialogEdit,
  DialogFormItemCreatedDate,
  DialogInspect,
  DialogInspectItemBoolean,
  DialogInspectItemList,
  DialogInspectItemText,
} from '#components'
import { deleteIcon } from '#shared/constants'

export default function useFitnessDialogs() {
  const $q = useQuasar()
  const logger = useLogger()
  const supabase = useSupabaseClient<Database>()

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
          record: {},
          // TODO - Created date should not be included for record creation for 99% of cases
          subComponents: [{ component: DialogFormItemCreatedDate }],
          onSubmitHandler: () => logger.info('Create Workout Handler'),
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
          subComponents: [{ component: DialogFormItemCreatedDate }],
          onSubmitHandler: () => logger.info('Edit Workout Handler'),
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
          const { data, error } = await supabase.from('workouts').delete().eq('id', id)
          if (error) throw error
          logger.info('Workout deleted', { result: data })
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

  return { openInspectWorkout, openCreateWorkout, openEditWorkout, openDeleteWorkout }
}
