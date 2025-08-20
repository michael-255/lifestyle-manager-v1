<script setup lang="ts">
const logger = useLogger()
const supabase = useSupabaseClient<Database>()
const localRecordStore = useLocalRecordStore()

const label = 'Workout'

localRecordStore.record = {
  name: '',
  description: '',
  created_at: new Date().toISOString(),
  schedule: null,
  exercises: [],
}

async function onSubmit() {
  const { error } = await supabase.rpc('create_workout', {
    w_name: localRecordStore.record.name,
    w_description: localRecordStore.record.description,
    w_created_at: localRecordStore.record.created_at,
    w_schedule: localRecordStore.record.schedule,
    w_exercise_ids: localRecordStore.record.exercises.map((id: string) => id),
  })
  if (error) throw error

  logger.info('Workout created', { name: localRecordStore.record.name })
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
