<script setup lang="ts">
const recordStore = useRecordStore()

const allowedTypes: ExerciseType[] = ['Weightlifting', 'Sided Weightlifting']

recordStore.record.initial_sets = recordStore.record.initial_sets || 1

const options = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
</script>

<template>
  <DialogSharedBaseItemForm
    v-if="allowedTypes.includes(recordStore.record.type)"
    label="Initial Sets"
  >
    <QItemLabel>
      <QSelect
        v-model="recordStore.record.initial_sets"
        :options="options"
        emit-value
        map-options
        options-dense
        dense
        outlined
        color="primary"
      />
    </QItemLabel>
  </DialogSharedBaseItemForm>
</template>
