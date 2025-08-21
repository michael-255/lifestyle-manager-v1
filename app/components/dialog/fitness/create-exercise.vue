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
  type: null,
  checklist_labels: null,
  initial_sets: null,
}

async function onSubmit() {
  const exerciseType: ExerciseType = recordStore.record.type

  if (exerciseType !== 'Checklist') {
    recordStore.record.checklist_labels = null
  }

  if (exerciseType !== 'Weightlifting' && exerciseType !== 'Sided Weightlifting') {
    recordStore.record.initial_sets = null
  }

  const { error } = await supabase.rpc('create_exercise', {
    e_name: recordStore.record.name,
    e_description: recordStore.record.description,
    e_created_at: recordStore.record.created_at,
    e_rest_timer: recordStore.record.rest_timer,
    e_type: recordStore.record.type,
    e_checklist_labels: recordStore.record.checklist_labels,
    e_initial_sets: recordStore.record.initial_sets,
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
    <DialogFitnessFormExerciseType />
    <DialogFitnessFormChecklistLabels />
    <DialogFitnessFormInitialSets />
  </DialogCreate>
</template>
