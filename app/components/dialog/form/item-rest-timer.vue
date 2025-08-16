<script setup lang="ts">
const localRecordStore = useLocalRecordStore()
// TODO: Change this to a select box that defaults to "Off"
</script>

<template>
  <DialogFormItem label="Rest Timer">
    <QItemLabel>
      <QSlider
        v-model="localRecordStore.record.rest_timer"
        :min="0"
        :max="300"
        :step="30"
        :label-value="timeFromDuration(localRecordStore.record.rest_timer)"
        markers
        track-size="0.5rem"
        thumb-size="1.25rem"
        label-always
        switch-label-side
        color="primary"
        class="q-mb-md"
      />
    </QItemLabel>
  </DialogFormItem>
</template>
