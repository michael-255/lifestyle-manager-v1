<script setup lang="ts">
const logger = useLogger()
const supabase = useSupabaseClient<Database>()
const localRecordStore = useLocalRecordStore()

const label = 'Exercise'

localRecordStore.record = {
  name: '',
  description: '',
  created_at: new Date().toISOString(),
  rest_timer: 0,
  type: null,
  checklist_labels: [],
  initial_sets: 1,
}

async function onSubmit() {
  const { error } = await supabase.rpc('create_exercise', {
    // TODO: missing params?
    e_name: localRecordStore.record.name,
    e_description: localRecordStore.record.description,
    e_rest_timer: localRecordStore.record.rest_timer,
    e_type: localRecordStore.record.type,
    e_checklist_labels: localRecordStore.record.checklist_labels,
    e_initial_sets: localRecordStore.record.initial_sets,
  })
  if (error) throw error

  logger.info('Exercise created', { name: localRecordStore.record.name })
}
</script>

<template>
  <DialogCreate :label="label" :on-submit-handler="onSubmit" :is-loading="false">
    <DialogSharedFormName />
    <DialogSharedFormDescription />
    <DialogSharedFormCreatedDate />
    <DialogFitnessFormRestTimer />
    <DialogFitnessFormExerciseType />
    <DialogFitnessFormChecklistLabels />
    <DialogFitnessFormInitialSets />
  </DialogCreate>
</template>
