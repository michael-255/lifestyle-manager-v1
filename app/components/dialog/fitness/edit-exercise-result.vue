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

    const { data, error } = await supabase.rpc('inspect_exercise_result', { er_id: props.id })
    if (error) throw error

    const res = inspectExerciseResultResponseSchema.parse(data)

    recordStore.record = {
      ...res.exercise_result,
      exercise: res.exercise,
    }
  } catch (error) {
    logger.error('Error opening exercise result edit dialog', error as Error)
  } finally {
    isLoading.value = false
    $q.loading.hide()
  }
})

async function onSubmit() {
  const { error } = await supabase.rpc('edit_exercise_result', {
    er_id: props.id,
    er_created_at: recordStore.record.created_at,
    er_checked: recordStore.record.checked,
    er_note: recordStore.record.note,
  })
  if (error) throw error

  logger.info('Exercise result updated', { id: props.id })
}
</script>

<template>
  <DialogEdit label="Exercise Result" :on-submit-handler="onSubmit" :is-loading>
    <DialogSharedFormCreatedDate />
    <DialogSharedFormNote />
    <DialogFitnessFormExerciseChecked />
  </DialogEdit>
</template>
