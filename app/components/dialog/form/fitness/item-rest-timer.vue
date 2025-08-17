<script setup lang="ts">
const localRecordStore = useLocalRecordStore()

if (
  localRecordStore.record.rest_timer === null ||
  localRecordStore.record.rest_timer === undefined
) {
  localRecordStore.record.rest_timer = 0
}

const options = [
  { label: 'None', value: 0 },
  { label: '30 seconds', value: 30 },
  { label: '60 seconds', value: 60 },
  { label: '90 seconds', value: 90 },
  { label: '2 minutes', value: 120 },
  { label: '3 minutes', value: 180 },
  { label: '4 minutes', value: 240 },
  { label: '5 minutes', value: 300 },
]
</script>

<template>
  <DialogFormSharedItem label="Rest Timer" class="q-mb-md">
    <QItemLabel>
      <QSelect
        v-model="localRecordStore.record.rest_timer"
        :options="options"
        lazy-rules
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
