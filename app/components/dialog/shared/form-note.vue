<script setup lang="ts">
import { cancelIcon } from '#shared/constants'
import { limitRuleLookup } from '#shared/utils/utils'

const recordStore = useRecordStore()
</script>

<template>
  <DialogSharedBaseItemForm label="Notes">
    <QItemLabel>
      <QInput
        v-model="recordStore.record.note"
        :rules="[
          (val: string) =>
            !val ||
            val.length <= limitRuleLookup.maxTextArea ||
            `Notes cannot exceed ${limitRuleLookup.maxTextArea} characters`,
        ]"
        :maxlength="limitRuleLookup.maxTextArea"
        type="textarea"
        lazy-rules
        autogrow
        counter
        dense
        outlined
        color="primary"
        @blur="recordStore.record.note = recordStore.record?.note?.trim()"
      >
        <template #append>
          <QIcon
            v-if="recordStore.record.note && recordStore.record.note !== ''"
            class="cursor-pointer"
            :name="cancelIcon"
            @click="recordStore.record.note = ''"
          />
        </template>
      </QInput>
    </QItemLabel>
  </DialogSharedBaseItemForm>
</template>
