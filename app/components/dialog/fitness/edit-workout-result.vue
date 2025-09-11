<script setup lang="ts">
const props = defineProps<{
  id: IdType
}>()

type Exercise = {
  name: string
  description: string
  rest_timer: number
  checklist: string[]
}

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

    if (typeof resultData.exercise_results === 'string') {
      resultData.exercise_results = JSON.parse(resultData.exercise_results)
    } else if (!resultData.exercise_results) {
      resultData.exercise_results = []
    }

    if (typeof workoutData.exercises === 'string') {
      workoutData.exercises = JSON.parse(workoutData.exercises)
    } else if (!workoutData.exercises) {
      workoutData.exercises = []
    }

    // Ensure exercise_results is initialized with correct structure
    if (
      !Array.isArray(resultData.exercise_results) ||
      resultData.exercise_results.length !==
        (Array.isArray(workoutData.exercises) ? workoutData.exercises.length : 0)
    ) {
      resultData.exercise_results = (workoutData.exercises as Exercise[]).map((ex) => ({
        note: '',
        checked: Array.isArray(ex.checklist) ? ex.checklist.map(() => false) : [false],
      }))
    }

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
