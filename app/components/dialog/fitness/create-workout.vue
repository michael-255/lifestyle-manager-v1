<script setup lang="ts">
const logger = useLogger()
const supabase = useSupabaseClient<Database>()
const recordStore = useRecordStore()

const label = 'Workout'

recordStore.record = {
  name: '',
  description: '',
  created_at: new Date().toISOString(),
  schedule: null,
  exercises: null,
}

async function onSubmit() {
  const { error } = await supabase.rpc('create_workout', {
    w_name: recordStore.record.name,
    w_description: recordStore.record.description,
    w_created_at: recordStore.record.created_at,
    w_schedule: recordStore.record.schedule,
    w_exercise_ids: recordStore.record.exercises.map((id: string) => id),
  })
  if (error) throw error

  logger.info('Workout created', { name: recordStore.record.name })
}
</script>

<template>
  <DialogCreate :label="label" :on-submit-handler="onSubmit" :is-loading="false">
    <DialogSharedFormName />
    <DialogSharedFormDescription />
    <DialogSharedFormCreatedDate />
    <DialogFitnessFormWorkoutExercises />
    <DialogFitnessFormWorkoutSchedule />
  </DialogCreate>
</template>
