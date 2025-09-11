<script setup lang="ts">
import { ref } from 'vue'
import { cancelIcon, removeIcon } from '~~/shared/constants'
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
    exercises.value.push({ name: '', description: '', rest_timer: 0, checklist: [''] })
  }
}

function removeExercise(idx: number) {
  exercises.value.splice(idx, 1)
}

function addChecklistItem(exIdx: number) {
  const exercise = exercises.value[exIdx]
  if (exercise && exercise.checklist.length < 20) {
    exercise.checklist.push('')
  }
  // Ensure at least one item exists
  if (exercise && exercise.checklist.length === 0) {
    exercise.checklist.push('')
  }
}

function removeChecklistItem(exIdx: number, itemIdx: number) {
  const exercise = exercises.value[exIdx]
  if (exercise && exercise.checklist && exercise.checklist.length > 1) {
    exercise.checklist.splice(itemIdx, 1)
  }
  // Do nothing if only one item left
}

watch(
  exercises,
  (val) => {
    recordStore.record.exercises = val
  },
  { deep: true },
)
</script>

<template>
  <QItem>
    <QItemSection>
      <QItemLabel class="text-body1">Exercises (limit 20)</QItemLabel>

      <QItemLabel>
        <QBtn
          color="positive"
          :disable="exercises.length >= 20"
          label="Add Exercise"
          @click="addExercise"
        />
      </QItemLabel>
    </QItemSection>
  </QItem>

  <div v-for="(exercise, exIdx) in exercises" :key="exIdx">
    <QSeparator inset class="q-mb-xs" />

    <QItem>
      <QItemSection>
        <QItemLabel class="text-body1">Exercise {{ exIdx + 1 }} </QItemLabel>
      </QItemSection>
      <QItemSection side>
        <QItemLabel>
          <QBtn color="negative" label="Remove Exercise" @click="removeExercise(exIdx)" />
        </QItemLabel>
      </QItemSection>
    </QItem>

    <DialogSharedBaseItemForm label="Name">
      <QItemLabel>
        <QInput
          v-model="exercise.name"
          :rules="[
            (val: string) => (!!val && val.trim().length >= 1) || 'Name is required',
            (val: string) =>
              !val ||
              val.length <= limitRuleLookup.maxTextLabel ||
              `Name cannot exceed ${limitRuleLookup.maxTextLabel} characters`,
          ]"
          :maxlength="limitRuleLookup.maxTextLabel"
          type="text"
          lazy-rules
          counter
          dense
          outlined
          color="primary"
          @blur="exercise.name = exercise.name?.trim()"
        >
          <template #append>
            <QIcon
              v-if="exercise.name && exercise.name !== ''"
              class="cursor-pointer"
              :name="cancelIcon"
              @click="exercise.name = ''"
            />
          </template>
        </QInput>
      </QItemLabel>
    </DialogSharedBaseItemForm>

    <DialogSharedBaseItemForm label="Description">
      <QItemLabel>
        <QInput
          v-model="exercise.description"
          :rules="[
            (val: string) =>
              !val ||
              val.length <= limitRuleLookup.maxTextArea ||
              `Description cannot exceed ${limitRuleLookup.maxTextArea} characters`,
          ]"
          :maxlength="limitRuleLookup.maxTextArea"
          type="textarea"
          lazy-rules
          autogrow
          counter
          dense
          outlined
          color="primary"
          @blur="exercise.description = exercise.description?.trim()"
        >
          <template #append>
            <QIcon
              v-if="exercise.description && exercise.description !== ''"
              class="cursor-pointer"
              :name="cancelIcon"
              @click="exercise.description = ''"
            />
          </template>
        </QInput>
      </QItemLabel>
    </DialogSharedBaseItemForm>

    <DialogSharedBaseItemForm label="Rest Timer" class="q-mb-md">
      <QItemLabel>
        <QSelect
          v-model="exercise.rest_timer"
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

    <DialogSharedBaseItemForm label="Checklist (limit 20)" class="q-mb-md">
      <QItemLabel>
        <QBtn
          color="positive"
          :disable="exercise.checklist.length >= 20"
          label="Add Item"
          class="q-mb-sm"
          @click="addChecklistItem(exIdx)"
        />
      </QItemLabel>
      <QItemLabel>
        <div v-for="(item, itemIdx) in exercise.checklist" :key="itemIdx">
          <QInput
            v-model="exercise.checklist[itemIdx]"
            :rules="[
              (val: string) => (!!val && val.trim().length >= 1) || 'Checklist text is required',
              (val: string) =>
                !val ||
                val.length <= limitRuleLookup.maxTextLabel ||
                `Checklist text cannot exceed ${limitRuleLookup.maxTextLabel} characters`,
            ]"
            :maxlength="limitRuleLookup.maxTextLabel"
            type="text"
            lazy-rules
            counter
            dense
            outlined
            color="primary"
            :label="`Item ${itemIdx + 1}`"
            @blur="exercise.checklist[itemIdx] = exercise.checklist[itemIdx]?.trim() || ''"
          >
            <template #append>
              <QIcon
                v-if="exercise.checklist[itemIdx] && exercise.checklist[itemIdx] !== ''"
                class="cursor-pointer"
                :name="cancelIcon"
                @click="exercise.checklist[itemIdx] = ''"
              />
            </template>
            <template #after>
              <QBtn
                round
                color="negative"
                :icon="removeIcon"
                :disable="exercise.checklist.length === 1"
                @click="removeChecklistItem(exIdx, itemIdx)"
              />
            </template>
          </QInput>
        </div>
      </QItemLabel>
    </DialogSharedBaseItemForm>
  </div>
</template>
