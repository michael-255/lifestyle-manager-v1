<script setup lang="ts">
defineProps<{
  exercise: Record<string, any>
  totalResults: number
  workoutsUsed: Record<string, any>[]
}>()
</script>

<template>
  <DialogInspectSharedItemText label="Id" :value="exercise.id" />
  <DialogInspectSharedItemText label="User Id" :value="exercise.user_id" />
  <DialogInspectSharedItemDate label="Created At" :value="exercise.created_at" />
  <DialogInspectSharedItemText label="Name" :value="exercise.name" />
  <DialogInspectSharedItemText label="Description" :value="exercise.description" />
  <DialogInspectSharedItemText label="Rest Timer" :value="exercise.rest_timer" />
  <DialogInspectSharedItemText label="Type" :value="exercise.type" />
  <DialogInspectSharedItemList label="Checklist Labels" :value="exercise.checklist_labels" />
  <DialogInspectSharedItemText label="Initial Sets" :value="exercise.initial_sets" />
  <DialogInspectSharedItemText label="Total Results" :value="totalResults" />
  <DialogInspectSharedItemObjectList label="Workouts Used" :value="workoutsUsed" />
  <DialogInspectSharedItemBoolean label="Locked" :value="exercise.is_locked" />
</template>
