<script setup lang="ts">
import { computed } from 'vue'

const localRecordStore = useLocalRecordStore()

const scheduleOptions = Constants.public.Enums.workout_schedule_type

const weekDayOptions = scheduleOptions.filter((opt) => opt.includes('day'))
const specialOptions = scheduleOptions.filter((opt) => !opt.includes('day'))

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
            v-for="option in weekDayOptions"
            :key="option"
            v-model="schedule"
            :val="option"
            :label="option"
            color="primary"
          />
        </div>

        <div class="col column">
          <QCheckbox
            v-for="option in specialOptions"
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
