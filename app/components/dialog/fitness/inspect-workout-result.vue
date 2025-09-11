<script setup lang="ts">
const props = defineProps<{
  id: IdType
}>()

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()

const isLoading = ref(true)
const workoutResult: Ref<Record<string, any>> = ref({})

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase
      .from('workout_results')
      .select('*')
      .eq('id', props.id)
      .single()
    if (error) throw error

    workoutResult.value = data
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
    <DialogSharedInspectDate label="Finished At" :value="workoutResult.finished_at" />
    <DialogSharedInspectText label="Note" :value="workoutResult.note" />
    <DialogSharedInspectObjectList
      label="Exercise Results"
      :value="workoutResult.exercise_results"
    />
    <DialogSharedInspectBoolean label="Active Workout" :value="workoutResult.is_active" />
  </DialogInspect>
</template>
