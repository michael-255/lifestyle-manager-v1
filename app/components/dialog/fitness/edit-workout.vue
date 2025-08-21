<script setup lang="ts">
const props = defineProps<{
  id: IdType
}>()

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()
const recordStore = useRecordStore()

const label = 'Workout'

const isLoading = ref(true)

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase.rpc('inspect_workout', { w_id: props.id })
    if (error) throw error

    const res = inspectWorkoutResponseSchema.parse(data)

    recordStore.record = {
      ...res.workout,
      exercises: res.exercises?.map((e) => e.id) || [],
    }
  } catch (error) {
    logger.error('Error opening workout edit dialog', error as Error)
  } finally {
    isLoading.value = false
    $q.loading.hide()
  }
})

async function onSubmit() {
  const exerciseIds = recordStore.record.exercises?.map((id: string) => id) || []

  const { error } = await supabase.rpc('edit_workout', {
    w_id: props.id,
    w_name: recordStore.record.name,
    w_description: recordStore.record.description,
    w_created_at: recordStore.record.created_at,
    w_schedule: recordStore.record.schedule,
    w_exercise_ids: exerciseIds,
  })
  if (error) throw error

  logger.info('Workout updated', { id: props.id })
}
</script>

<template>
  <DialogEdit :label="label" :on-submit-handler="onSubmit" :is-loading>
    <DialogSharedFormName />
    <DialogSharedFormDescription />
    <DialogSharedFormCreatedDate />
    <DialogFitnessFormWorkoutExercises />
    <DialogFitnessFormWorkoutSchedule />
  </DialogEdit>
</template>
