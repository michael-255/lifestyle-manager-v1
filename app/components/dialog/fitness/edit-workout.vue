<script setup lang="ts">
const props = defineProps<{
  id: IdType
}>()

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()
const localRecordStore = useLocalRecordStore()

const label = 'Workout'

const isLoading = ref(true)

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase.rpc('inspect_workout', { w_id: props.id })
    if (error) throw error

    const res = inspectWorkoutResponseSchema.parse(data)

    localRecordStore.record = {
      ...res.workout,
      exercises: res.exercises?.map((e) => e.id) || [],
    }
  } catch (error) {
    logger.error('Error opening workout edit dialog', error as Error)
  } finally {
    isLoading.value = false
    $q.loading.hide()
  }
})

async function onSubmit() {
  const { error } = await supabase.rpc('edit_workout', {
    w_id: props.id,
    w_name: localRecordStore.record.name,
    w_description: localRecordStore.record.description,
    w_created_at: localRecordStore.record.created_at,
    w_schedule: localRecordStore.record.schedule,
    w_exercise_ids: localRecordStore.record.exercises.map((id: string) => id),
  })
  if (error) throw error

  logger.info('Workout updated', { id: props.id })
}
</script>

<template>
  <DialogEdit :label="label" :on-submit-handler="onSubmit" :is-loading>
    <DialogSharedFormName />
    <DialogSharedFormDescription />
    <DialogSharedFormCreatedDate />
    <DialogFitnessFormWorkoutExercises />
    <DialogFitnessFormWorkoutSchedule />
  </DialogEdit>
</template>
