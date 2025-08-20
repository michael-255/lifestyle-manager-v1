<script setup lang="ts">
import {
  calendarClearIcon,
  calendarIcon,
  localPickerDateFormat,
  scheduleTimeIcon,
} from '#shared/constants'
import { localDisplayDate, localPickerDate } from '#shared/utils/utils'
import { computed, ref, watch } from 'vue'

const localRecordStore = useLocalRecordStore()

const dateTimePicker = ref(localPickerDate(localRecordStore.record?.created_at))
const displayDate = computed(() => localDisplayDate(localRecordStore.record?.created_at))

watch(dateTimePicker, () => {
  if (dateTimePicker.value) {
    // Convert back to UTC string for the store
    localRecordStore.record.created_at = new Date(dateTimePicker.value).toISOString()
  }
})

function onClear() {
  localRecordStore.record.created_at = null
  dateTimePicker.value = localPickerDate('')
}
</script>

<template>
  <DialogSharedBaseItemForm label="Finished Date" class="q-mb-md">
    <QItemLabel class="q-pt-xs text-body2">{{ displayDate }}</QItemLabel>

    <QItemLabel class="q-gutter-sm">
      <QBtn :icon="calendarIcon" size="sm" label="Date" color="primary">
        <QPopupProxy>
          <QDate v-model="dateTimePicker" :mask="localPickerDateFormat" today-btn no-unset>
            <QBtn v-close-popup flat dense label="Close" />
          </QDate>
        </QPopupProxy>
      </QBtn>

      <QBtn :icon="scheduleTimeIcon" size="sm" label="Time" color="primary">
        <QPopupProxy>
          <QTime v-model="dateTimePicker" :mask="localPickerDateFormat" now-btn>
            <QBtn v-close-popup flat dense label="Close" />
          </QTime>
        </QPopupProxy>
      </QBtn>

      <QBtn :icon="calendarClearIcon" size="sm" color="negative" @click="onClear" />
    </QItemLabel>
  </DialogSharedBaseItemForm>
</template>
