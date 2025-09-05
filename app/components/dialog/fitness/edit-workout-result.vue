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

    const { data: resultData, error: resultError } = await supabase
      .from('workout_results')
      .select('*')
      .eq('id', props.id)
      .single()
    if (resultError) throw resultError

    const { data: workoutData, error: workoutError } = await supabase
      .from('workouts')
      .select('exercises')
      .eq('id', resultData.workout_id)
      .single()
    if (workoutError) throw workoutError

    recordStore.record = {
      ...resultData,
      exercises: workoutData.exercises,
    }
  } catch (error) {
    logger.error('Error opening workout result edit dialog', error as Error)
  } finally {
    isLoading.value = false
    $q.loading.hide()
  }
})

async function onSubmit() {
  const { error } = await supabase
    .from('workout_results')
    .update({
      name: recordStore.record.name,
      description: recordStore.record.description,
      created_at: recordStore.record.created_at,
      finished_at: recordStore.record.finished_at,
      note: recordStore.record.note,
      exercise_results: recordStore.record.exercise_results,
    })
    .eq('id', props.id)
  if (error) throw error

  logger.info('Workout result updated', { id: props.id })
}
</script>

<template>
  <DialogEdit label="Workout Result" :on-submit-handler="onSubmit" :is-loading>
    <DialogSharedFormCreatedDate />
    <DialogFitnessFormFinishedDate />
    <DialogSharedFormNote />
    <DialogFitnessFormWorkoutExerciseResults />
  </DialogEdit>
</template>
