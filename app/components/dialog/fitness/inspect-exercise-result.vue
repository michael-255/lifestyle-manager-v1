<script setup lang="ts">
import {
  inspectExerciseResultResponseSchema,
  type InspectExerciseResultResponse,
} from '#shared/types/fitness-schemas'

const props = defineProps<{
  id: IdType
}>()

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()

const isLoading = ref(true)
const exercise = ref({} as InspectExerciseResultResponse['exercise'])
const exerciseResult = ref({} as InspectExerciseResultResponse['exercise_result'])

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase.rpc('inspect_exercise_result', { er_id: props.id })
    if (error) throw error

    const res = inspectExerciseResultResponseSchema.parse(data)

    exerciseResult.value = res.exercise_result
    exercise.value = res.exercise
  } catch (error) {
    logger.error('Error opening exercise inspect dialog', error as Error)
  } finally {
    isLoading.value = false
    $q.loading.hide()
  }
})
</script>

<template>
  <DialogInspect label="Exercise Result" :is-loading>
    <DialogSharedInspectText label="Id" :value="exerciseResult.id" />
    <DialogSharedInspectDate label="Created At" :value="exerciseResult.created_at" />
    <DialogSharedInspectText label="Parent Name" :value="exercise.name" />
    <DialogSharedInspectText label="Parent Description" :value="exercise.description" />
    <DialogSharedInspectList label="Checked" :value="exerciseResult.checked" />
    <DialogSharedInspectBoolean label="Active Workout" :value="exerciseResult.is_active" />
  </DialogInspect>
</template>
