<script setup lang="ts">
import { addIcon, removeIcon } from '#shared/constants'
import { ref } from 'vue'

const recordStore = useRecordStore()

const MAX_LABELS = 20
const checklist: Ref<string[]> = ref(recordStore.record.checklist || [''])

function updateChecklistLabels() {
  recordStore.record.checklist = checklist.value.filter((l) => l.trim().length > 0)
}

function removeChecklistLabel(idx: number) {
  if (checklist.value.length > 1) {
    checklist.value.splice(idx, 1)
    updateChecklistLabels()
  }
}
</script>

<template>
  <DialogSharedBaseItemForm label="Checklist">
    <QItemLabel>
      <QInput
        v-for="(label, idx) in checklist"
        :key="idx"
        v-model="checklist[idx]"
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
            :disable="checklist.length === 1"
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
        :disable="checklist.length >= MAX_LABELS"
        @click="checklist.length < MAX_LABELS && checklist.push('')"
      />
    </QItemLabel>
  </DialogSharedBaseItemForm>
</template>
