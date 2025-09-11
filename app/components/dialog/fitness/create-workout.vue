<script setup lang="ts">
const logger = useLogger()
const supabase = useSupabaseClient<Database>()
const recordStore = useRecordStore()

const label = 'Workout'

recordStore.record = {
  name: 'My Workout',
  description: '',
  created_at: new Date().toISOString(),
  schedule: null,
  exercises: [],
}

async function onSubmit() {
  const { data, error } = await supabase
    .from('workouts')
    .insert({
      name: recordStore.record.name,
      description: recordStore.record.description,
      created_at: recordStore.record.created_at,
      schedule: recordStore.record.schedule,
      exercises: recordStore.record.exercises,
    })
    .select()
    .single()

  if (error) throw error

  logger.info('Workout created', { name: recordStore.record.name, id: data.id })
}
</script>

<template>
  <DialogCreate :label="label" :on-submit-handler="onSubmit" :is-loading="false">
    <DialogSharedFormName />
    <DialogSharedFormDescription />
    <DialogSharedFormCreatedDate />
    <DialogFitnessFormWorkoutSchedule />
    <DialogFitnessFormWorkoutExercises />
  </DialogCreate>
</template>
