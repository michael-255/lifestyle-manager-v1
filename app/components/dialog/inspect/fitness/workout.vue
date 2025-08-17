<script setup lang="ts">
defineProps<{
  workout: Record<string, any>
  exercises: Record<string, any>[]
  lastWorkoutResult: Record<string, any>
}>()
</script>

<template>
  <DialogInspectSharedItemText label="Id" :value="workout.id" />
  <DialogInspectSharedItemText label="User Id" :value="workout.user_id" />
  <DialogInspectSharedItemDate label="Created At" :value="workout.created_at" />
  <DialogInspectSharedItemText label="Name" :value="workout.name" />
  <DialogInspectSharedItemText label="Description" :value="workout.description" />
  <DialogInspectSharedItemList label="Schedule" :value="workout.schedule" />
  <DialogInspectSharedItemObject label="Last Workout" :value="lastWorkoutResult" />
  <DialogInspectSharedItemObjectList label="Exercises" :value="exercises" />
  <DialogInspectSharedItemBoolean label="Locked" :value="workout.is_locked" />
</template>
