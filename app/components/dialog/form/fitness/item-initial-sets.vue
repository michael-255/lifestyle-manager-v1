<script setup lang="ts">
const localRecordStore = useLocalRecordStore()

const allowedTypes: ExerciseType[] = ['Weightlifting', 'Sided Weightlifting']

if (
  localRecordStore.record.initial_sets === null ||
  localRecordStore.record.initial_sets === undefined
) {
  localRecordStore.record.initial_sets = 1
}

const options = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
</script>

<template>
  <DialogFormSharedItem
    v-if="allowedTypes.includes(localRecordStore.record.type)"
    label="Initial Sets"
  >
    <QItemLabel>
      <QSelect
        v-model="localRecordStore.record.initial_sets"
        :options="options"
        emit-value
        map-options
        options-dense
        dense
        outlined
        color="primary"
      />
    </QItemLabel>
  </DialogFormSharedItem>
</template>
