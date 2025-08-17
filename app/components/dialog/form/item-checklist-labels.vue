<script setup lang="ts">
import { Constants } from '#shared/types/supabase'
import { ref } from 'vue'

const localRecordStore = useLocalRecordStore()
const checklistLabels: Ref<string[]> = ref(localRecordStore.record.checklist_labels || [])
</script>

<template>
  <DialogFormItem
    v-if="localRecordStore.record.type === Constants.public.Enums.exercise_type[0]"
    label="Checklist Labels"
  >
    <QItemLabel>
      <div>
        <div v-for="(label, idx) in checklistLabels" :key="idx" class="q-mb-xs row items-center">
          <QInput
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
            class="q-mr-sm"
            @blur="
              localRecordStore.record.checklist_labels = checklistLabels.filter(
                (l) => l.trim().length > 0,
              )
            "
          />
          <QBtn
            icon="remove_circle"
            color="negative"
            flat
            round
            dense
            @click="
              (checklistLabels.splice(idx, 1),
              (localRecordStore.record.checklist_labels = checklistLabels.filter(
                (l) => l.trim().length > 0,
              )))
            "
          />
        </div>
        <QBtn
          icon="add_circle"
          color="primary"
          flat
          round
          dense
          @click="checklistLabels.push('')"
        />
      </div>
    </QItemLabel>
  </DialogFormItem>
</template>
