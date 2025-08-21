<script setup lang="ts">
import type { InspectExerciseResponse } from '#shared/types/fitness-schemas'

const props = defineProps<{
  id: IdType
}>()

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()

const isLoading = ref(true)
const exercise = ref({} as InspectExerciseResponse['exercise'])
const totalResults = ref(0 as InspectExerciseResponse['total_results'])
const workoutsUsed = ref([] as InspectExerciseResponse['workouts_used'])

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase.rpc('inspect_exercise', { e_id: props.id })
    if (error) throw error

    const res = inspectExerciseResponseSchema.parse(data)

    exercise.value = res.exercise
    totalResults.value = res.total_results
    workoutsUsed.value = res.workouts_used
  } catch (error) {
    logger.error('Error opening exercise inspect dialog', error as Error)
  } finally {
    isLoading.value = false
    $q.loading.hide()
  }
})
</script>

<template>
  <DialogInspect label="Exercise" :is-loading>
    <DialogSharedInspectText label="Id" :value="exercise.id" />
    <DialogSharedInspectDate label="Created At" :value="exercise.created_at" />
    <DialogSharedInspectText label="Name" :value="exercise.name" />
    <DialogSharedInspectText label="Description" :value="exercise.description" />
    <DialogSharedInspectText label="Rest Timer" :value="exercise.rest_timer" />
    <DialogSharedInspectText label="Type" :value="exercise.type" />
    <DialogSharedInspectList label="Checklist Labels" :value="exercise.checklist_labels" />
    <DialogSharedInspectText label="Initial Sets" :value="exercise.initial_sets" />
    <DialogSharedInspectText label="Total Results" :value="totalResults" />
    <DialogSharedInspectObjectList label="Workouts Used" :value="workoutsUsed" />
    <DialogSharedInspectBoolean label="Active Workout" :value="exercise.is_active" />
  </DialogInspect>
</template>
