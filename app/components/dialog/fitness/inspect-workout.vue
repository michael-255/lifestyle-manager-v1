<script setup lang="ts">
import type { InspectWorkoutResponse } from '#shared/types/fitness-schemas'

const props = defineProps<{
  id: IdType
}>()

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()

const isLoading = ref(true)
const workout = ref({} as InspectWorkoutResponse['workout'])
const exercises = ref([] as InspectWorkoutResponse['exercises'])
const lastWorkoutResult = ref({} as InspectWorkoutResponse['last_workout_result'])

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase.rpc('inspect_workout', { w_id: props.id })
    if (error) throw error

    const res = inspectWorkoutResponseSchema.parse(data)

    workout.value = res.workout
    exercises.value = res.exercises
    lastWorkoutResult.value = res.last_workout_result
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
    <DialogSharedInspectText label="Id" :value="workout.id" />
    <DialogSharedInspectText label="User Id" :value="workout.user_id" />
    <DialogSharedInspectDate label="Created At" :value="workout.created_at" />
    <DialogSharedInspectText label="Name" :value="workout.name" />
    <DialogSharedInspectText label="Description" :value="workout.description" />
    <DialogSharedInspectList label="Schedule" :value="workout.schedule" />
    <DialogSharedInspectObject label="Last Workout" :value="lastWorkoutResult" />
    <DialogSharedInspectObjectList label="Exercises" :value="exercises" />
    <DialogSharedInspectBoolean label="Active Workout" :value="workout.is_active" />
  </DialogInspect>
</template>
