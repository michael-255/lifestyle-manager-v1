<script setup lang="ts">
import { Constants } from '#shared/types/supabase'

const localRecordStore = useLocalRecordStore()

const checklistLabels: Ref<string> = ref('')
</script>

<template>
  <DialogFormItem
    v-if="localRecordStore.record.type === Constants.public.Enums.exercise_type[0]"
    label="Checklist Labels"
  >
    <QItemLabel>
      <QInput
        v-model="checklistLabels"
        :rules="[
          (val: string) => (!!val && val.trim().length >= 1) || 'One label is required',
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
        @blur="localRecordStore.record.type_data.checklist_labels = checklistLabels.trim()"
      />
    </QItemLabel>
  </DialogFormItem>
</template>
