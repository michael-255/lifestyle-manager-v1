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

    const { data, error } = await supabase.from('workouts').select('*').eq('id', props.id).single()
    if (error) throw error

    recordStore.record = data
  } catch (error) {
    logger.error('Error opening workout edit dialog', error as Error)
  } finally {
    isLoading.value = false
    $q.loading.hide()
  }
})

async function onSubmit() {
  const { error } = await supabase
    .from('workouts')
    .update({
      name: recordStore.record.name,
      description: recordStore.record.description,
      created_at: recordStore.record.created_at,
      schedule: recordStore.record.schedule,
      exercises: recordStore.record.exercises,
    })
    .eq('id', props.id)
  if (error) throw error

  logger.info('Workout updated', { id: props.id })
}
</script>

<template>
  <DialogEdit label="Workout" :on-submit-handler="onSubmit" :is-loading>
    <DialogSharedFormName />
    <DialogSharedFormDescription />
    <DialogSharedFormCreatedDate />
    <DialogFitnessFormWorkoutSchedule />
    <DialogFitnessFormWorkoutExercises />
  </DialogEdit>
</template>
