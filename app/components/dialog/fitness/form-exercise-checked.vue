<script setup lang="ts">
const recordStore = useRecordStore()
</script>

<template>
  <DialogSharedBaseItemForm label="Checked">
    <QItemLabel>
      <div v-for="(label, idx) in recordStore.record.exercise.checklist" :key="label">
        <QCheckbox
          :label="label"
          :model-value="
            Array.isArray(recordStore.record.checked) &&
            typeof recordStore.record.checked[idx] === 'boolean'
              ? recordStore.record.checked[idx]
              : (recordStore.record.checked[idx] = false)
          "
          @update:model-value="
            (checked) => {
              if (!Array.isArray(recordStore.record.checked)) {
                recordStore.record.checked = []
              }
              // Fill missing values with false up to idx
              while (recordStore.record.checked.length <= idx) {
                recordStore.record.checked.push(false)
              }
              recordStore.record.checked[idx] = checked
            }
          "
        />
      </div>
    </QItemLabel>
  </DialogSharedBaseItemForm>
</template>
