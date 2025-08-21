<script setup lang="ts">
import { addIcon, removeIcon } from '#shared/constants'
import { ref } from 'vue'

const recordStore = useRecordStore()

const allowedTypes: ExerciseType[] = ['Checklist']

const MAX_LABELS = 20
const checklistLabels: Ref<string[]> = ref(recordStore.record.checklist_labels || [''])

function updateChecklistLabels() {
  recordStore.record.checklist_labels = checklistLabels.value.filter((l) => l.trim().length > 0)
}

function removeChecklistLabel(idx: number) {
  if (checklistLabels.value.length > 1) {
    checklistLabels.value.splice(idx, 1)
    updateChecklistLabels()
  }
}
</script>

<template>
  <DialogSharedBaseItemForm
    v-if="allowedTypes.includes(recordStore.record.type)"
    label="Checklist Labels"
  >
    <QItemLabel v-if="recordStore.action === 'EDIT'">
      <ul
        v-if="
          recordStore.record.checklist_labels && recordStore.record.checklist_labels?.length > 0
        "
        class="q-pl-sm q-my-none"
      >
        <li
          v-for="label in recordStore.record.checklist_labels"
          :key="label"
          class="q-ml-sm q-mb-xs"
        >
          {{ label }}
        </li>
      </ul>
    </QItemLabel>

    <QItemLabel v-else>
      <QInput
        v-for="(label, idx) in checklistLabels"
        :key="idx"
        v-model="checklistLabels[idx]"
        :rules="[
          (val: string) => (!!val && val.trim().length >= 1) || 'Label required',
          (val: string) =>
            !val ||
            val.length <= limitRuleLookup.maxTextLabel ||
            `Labels cannot exceed ${limitRuleLookup.maxTextLabel} characters`,
        ]"
        :maxlength="limitRuleLookup.maxTextLabel"
        type="text"
        lazy-rules
        counter
        dense
        outlined
        color="primary"
        @blur="updateChecklistLabels()"
      >
        <template #after>
          <QBtn
            :icon="removeIcon"
            :disable="checklistLabels.length === 1"
            color="negative"
            round
            @click="removeChecklistLabel(idx)"
          />
        </template>
      </QInput>

      <QBtn
        :icon="addIcon"
        color="primary"
        round
        :disable="checklistLabels.length >= MAX_LABELS"
        @click="checklistLabels.length < MAX_LABELS && checklistLabels.push('')"
      />
    </QItemLabel>
  </DialogSharedBaseItemForm>
</template>
