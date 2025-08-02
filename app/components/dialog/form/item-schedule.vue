<script setup lang="ts">
import { computed } from 'vue'

// TODO

const localRecordStore = useLocalRecordStore()

const scheduleOptions = [
  'Daily',
  'Weekly',
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
]

// Split options into two columns
const mid = Math.ceil(scheduleOptions.length / 2)
const col1 = scheduleOptions.slice(0, mid)
const col2 = scheduleOptions.slice(mid)

// Ensure schedule is always an array
const schedule = computed({
  get: () => localRecordStore.record.schedule || [],
  set: (val) => (localRecordStore.record.schedule = val),
})
</script>

<template>
  <DialogFormItem label="Schedule">
    <QItemLabel>
      <div class="row">
        <div class="col column">
          <QCheckbox
            v-for="option in col1"
            :key="option"
            v-model="schedule"
            :val="option"
            :label="option"
            color="primary"
          />
        </div>

        <div class="col column">
          <QCheckbox
            v-for="option in col2"
            :key="option"
            v-model="schedule"
            :val="option"
            :label="option"
            color="primary"
          />
        </div>
      </div>
    </QItemLabel>
  </DialogFormItem>
</template>
