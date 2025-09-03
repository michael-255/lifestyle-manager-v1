<script setup lang="ts">
import { ref } from 'vue'
const recordStore = useRecordStore()

type Exercise = {
  name: string
  description: string
  rest_timer: number
  checklist: string[]
}

const exercises = ref<Exercise[]>(recordStore.record.exercises || [])

const restTimerOptions = [
  { label: 'None', value: 0 },
  { label: '30 seconds', value: 30 },
  { label: '60 seconds', value: 60 },
  { label: '90 seconds', value: 90 },
  { label: '2 minutes', value: 120 },
  { label: '3 minutes', value: 180 },
  { label: '4 minutes', value: 240 },
  { label: '5 minutes', value: 300 },
]

function addExercise() {
  if (exercises.value.length < 20) {
    exercises.value.push({ name: '', description: '', rest_timer: 0, checklist: [] })
  }
}

function removeExercise(idx: number) {
  exercises.value.splice(idx, 1)
}

function addChecklistItem(exIdx: number) {
  if (exercises.value[exIdx].checklist.length < 20) {
    exercises.value[exIdx].checklist.push('')
  }
}

function removeChecklistItem(exIdx: number, itemIdx: number) {
  exercises.value[exIdx].checklist.splice(itemIdx, 1)
}

// Sync with recordStore
watch(
  exercises,
  (val) => {
    recordStore.record.exercises = val
  },
  { deep: true },
)
</script>

<template>
  <DialogSharedBaseItemForm label="Exercises">
    <QItemLabel>
      <div>
        <QBtn color="primary" :disable="exercises.length >= 20" @click="addExercise">
          Add Exercise
        </QBtn>
      </div>

      <QCard v-for="(exercise, exIdx) in exercises" :key="exIdx">
        <QInput v-model="exercise.name" label="Name" outlined dense class="q-mb-sm" />
        <QInput v-model="exercise.description" label="Description" outlined dense class="q-mb-sm" />

        <DialogSharedBaseItemForm label="Rest Timer" class="q-mb-md">
          <QItemLabel>
            <QSelect
              v-model="recordStore.record.rest_timer"
              :options="restTimerOptions"
              lazy-rules
              emit-value
              map-options
              options-dense
              dense
              outlined
              color="primary"
            />
          </QItemLabel>
        </DialogSharedBaseItemForm>

        <div>
          <label>Checklist (up to 20 items):</label>
          <QBtn
            size="sm"
            color="primary"
            :disable="exercise.checklist.length >= 20"
            @click="addChecklistItem(exIdx)"
            >Add Item</QBtn
          >
          <div v-for="(item, itemIdx) in exercise.checklist" :key="itemIdx" class="q-mt-xs">
            <QInput
              v-model="exercise.checklist[itemIdx]"
              label="Checklist Item"
              outlined
              dense
              class="q-mr-sm"
            />
            <QBtn size="sm" color="negative" @click="removeChecklistItem(exIdx, itemIdx)"
              >Remove</QBtn
            >
          </div>
        </div>
        <QBtn color="negative" class="q-mt-sm" @click="removeExercise(exIdx)">Remove Exercise</QBtn>
      </QCard>
    </QItemLabel>
  </DialogSharedBaseItemForm>
</template>
