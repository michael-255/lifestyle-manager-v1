<script setup lang="ts">
const recordStore = useRecordStore()
// TODO
// Each exercise result contains: note (string), checked (boolean[])
// Map that to the Workout.exercises.checklist (string[])
</script>

<template>
  <DialogSharedBaseItemForm label="Checked">
    <QItemLabel>
      {{ recordStore.record.exercise_results }}
    </QItemLabel>
  </DialogSharedBaseItemForm>
</template>
