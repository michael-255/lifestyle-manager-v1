<script setup lang="ts">
import {
  inspectWorkoutResultResponseSchema,
  type InspectWorkoutResultResponse,
} from '#shared/types/fitness-schemas'

const props = defineProps<{
  id: IdType
}>()

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()

const isLoading = ref(true)
const workoutResult = ref({} as InspectWorkoutResultResponse['workout_result'])
const workout = ref({} as InspectWorkoutResultResponse['workout'])

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase.rpc('inspect_workout_result', { wr_id: props.id })
    if (error) throw error

    const res = inspectWorkoutResultResponseSchema.parse(data)

    workout.value = res.workout
    workoutResult.value = res.workout_result
  } catch (error) {
    logger.error('Error opening workout result inspect dialog', error as Error)
  } finally {
    isLoading.value = false
    $q.loading.hide()
  }
})
</script>

<template>
  <DialogInspect label="Workout Result" :is-loading>
    <DialogSharedInspectText label="Id" :value="workoutResult.id" />
    <DialogSharedInspectDate label="Created At" :value="workoutResult.created_at" />
    <DialogSharedInspectText label="Parent Name" :value="workout.name" />
    <DialogSharedInspectText label="Parent Description" :value="workout.description" />
    <DialogSharedInspectText label="Duration" :value="workoutResult.duration_seconds" />
    <DialogSharedInspectBoolean label="Active Workout" :value="workoutResult.is_active" />
  </DialogInspect>
</template>
