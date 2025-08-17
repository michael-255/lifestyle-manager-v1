<script setup lang="ts">
import { addIcon, removeIcon } from '#shared/constants'
import { ref } from 'vue'

const localRecordStore = useLocalRecordStore()

const allowedTypes: ExerciseType[] = ['Checklist']
const checklistLabels: Ref<string[]> = ref(localRecordStore.record.checklist_labels || [''])

function updateChecklistLabels() {
  localRecordStore.record.checklist_labels = checklistLabels.value.filter(
    (l) => l.trim().length > 0,
  )
}

function removeChecklistLabel(idx: number) {
  if (checklistLabels.value.length > 1) {
    checklistLabels.value.splice(idx, 1)
    updateChecklistLabels()
  }
}
</script>

<template>
  <DialogFormSharedItem
    v-if="allowedTypes.includes(localRecordStore.record.type)"
    label="Checklist Labels"
  >
    <QItemLabel v-if="localRecordStore.action === 'edit'">
      <span
        v-for="(label, idx) in localRecordStore.record.checklist_labels"
        :key="idx"
        class="text-body2"
      >
        {{ label }}<span v-if="idx < localRecordStore.record.checklist_labels.length - 1">, </span>
      </span>
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

      <QBtn :icon="addIcon" color="primary" round @click="checklistLabels.push('')" />
    </QItemLabel>
  </DialogFormSharedItem>
</template>
