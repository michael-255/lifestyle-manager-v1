<script setup lang="ts">
const props = defineProps<{
  id: IdType
}>()

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()

const isLoading = ref(true)
const workout: Ref<Record<string, any>> = ref({})

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase.from('workouts').select('*').eq('id', props.id).single()
    if (error) throw error

    workout.value = data
  } catch (error) {
    logger.error('Error opening workout inspect dialog', error as Error)
  } finally {
    isLoading.value = false
    $q.loading.hide()
  }
})
</script>

<template>
  <DialogInspect label="Exercise" :is-loading>
    <DialogSharedInspectText label="Id" :value="workout.id" />
    <DialogSharedInspectDate label="Created At" :value="workout.created_at" />
    <DialogSharedInspectText label="Name" :value="workout.name" />
    <DialogSharedInspectText label="Description" :value="workout.description" />
    <DialogSharedInspectList label="Schedule" :value="workout.schedule" />
    <DialogSharedInspectObjectList label="Exercises" :value="workout.exercises" />
    <DialogSharedInspectBoolean label="Active Workout" :value="workout.is_active" />
  </DialogInspect>
</template>
