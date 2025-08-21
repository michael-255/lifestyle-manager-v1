<script setup lang="ts">
import { computed } from 'vue'

const recordStore = useRecordStore()

const scheduleOptions = Constants.public.Enums.workout_schedule_type

const weekDayOptions = scheduleOptions.filter((opt) => opt.includes('day'))
const specialOptions = scheduleOptions.filter((opt) => !opt.includes('day'))

const schedule = computed({
  get: () => recordStore.record.schedule || [],
  set: (val) => (recordStore.record.schedule = val),
})
</script>

<template>
  <DialogSharedBaseItemForm label="Schedule">
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
  </DialogSharedBaseItemForm>
</template>
