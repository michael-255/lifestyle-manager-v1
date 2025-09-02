<script setup lang="ts">
const props = defineProps<{
  id: IdType
}>()

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()
const recordStore = useRecordStore()

const isLoading = ref(true)

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase.rpc('inspect_workout_result', { wr_id: props.id })
    if (error) throw error

    const res = inspectWorkoutResultResponseSchema.parse(data)

    recordStore.record = res.workout_result
  } catch (error) {
    logger.error('Error opening workout result edit dialog', error as Error)
  } finally {
    isLoading.value = false
    $q.loading.hide()
  }
})

async function onSubmit() {
  const { error } = await supabase.rpc('edit_workout_result', {
    wr_id: props.id,
    wr_created_at: recordStore.record.created_at,
    wr_finished_at: recordStore.record.finished_at,
    wr_note: recordStore.record.note,
  })
  if (error) throw error

  logger.info('Workout result updated', { id: props.id })
}
</script>

<template>
  <DialogEdit label="Workout Result" :on-submit-handler="onSubmit" :is-loading>
    <DialogSharedFormCreatedDate />
    <DialogFitnessFormFinishedDate />
    <DialogSharedFormNote />
  </DialogEdit>
</template>
