<script setup lang="ts">
const logger = useLogger()
const supabase = useSupabaseClient<Database>()
const recordStore = useRecordStore()

const label = 'Exercise'

recordStore.record = {
  name: '',
  description: '',
  created_at: new Date().toISOString(),
  rest_timer: 0,
  checklist: null,
}

async function onSubmit() {
  const { error } = await supabase.rpc('create_exercise', {
    e_name: recordStore.record.name,
    e_description: recordStore.record.description,
    e_created_at: recordStore.record.created_at,
    e_rest_timer: recordStore.record.rest_timer,
    e_checklist: recordStore.record.checklist,
  })
  if (error) throw error

  logger.info('Exercise created', { name: recordStore.record.name })
}
</script>

<template>
  <DialogCreate :label="label" :on-submit-handler="onSubmit" :is-loading="false">
    <DialogSharedFormName />
    <DialogSharedFormDescription />
    <DialogSharedFormCreatedDate />
    <DialogFitnessFormRestTimer />
    <DialogFitnessFormExerciseChecklist />
  </DialogCreate>
</template>
