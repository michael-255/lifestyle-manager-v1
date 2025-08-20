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
  checklist_labels: null,
  initial_sets: null,
}

async function onSubmit() {
  const exerciseType: ExerciseType = localRecordStore.record.type
  const checklistLabels =
    exerciseType === 'Checklist' ? localRecordStore.record.checklist_labels : null
  const initialSets =
    exerciseType === 'Weightlifting' || exerciseType === 'Sided Weightlifting'
      ? localRecordStore.record.initial_sets
      : null

  const { error } = await supabase.rpc('create_exercise', {
    e_name: localRecordStore.record.name,
    e_description: localRecordStore.record.description,
    e_created_at: localRecordStore.record.created_at,
    e_rest_timer: localRecordStore.record.rest_timer,
    e_type: localRecordStore.record.type,
    e_checklist_labels: checklistLabels,
    e_initial_sets: initialSets,
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
