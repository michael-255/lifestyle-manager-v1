<script setup lang="ts">
const props = defineProps<{
  id: IdType
}>()

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()
const recordStore = useRecordStore()

const label = 'Exercise'

const isLoading = ref(true)

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase.rpc('inspect_exercise', { e_id: props.id })
    if (error) throw error

    const res = inspectExerciseResponseSchema.parse(data)

    recordStore.record = res.exercise
  } catch (error) {
    logger.error('Error opening exercise edit dialog', error as Error)
  } finally {
    isLoading.value = false
    $q.loading.hide()
  }
})

async function onSubmit() {
  const { error } = await supabase.rpc('edit_exercise', {
    e_id: props.id,
    e_name: recordStore.record.name,
    e_description: recordStore.record.description,
    e_rest_timer: recordStore.record.rest_timer,
    e_initial_sets: recordStore.record.initial_sets,
  })
  if (error) throw error

  logger.info('Exercise updated', { id: props.id })
}
</script>

<template>
  <DialogEdit :label="label" :on-submit-handler="onSubmit" :is-loading>
    <DialogSharedFormName />
    <DialogSharedFormDescription />
    <DialogSharedFormCreatedDate />
    <DialogFitnessFormRestTimer />
    <DialogFitnessFormExerciseType />
    <DialogFitnessFormChecklistLabels />
    <DialogFitnessFormInitialSets />
  </DialogEdit>
</template>
