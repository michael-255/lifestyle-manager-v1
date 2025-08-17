<script setup lang="ts">
import { cancelIcon } from '#shared/constants'
import { limitRuleLookup } from '#shared/utils/utils'

const localRecordStore = useLocalRecordStore()
</script>

<template>
  <DialogFormSharedItem label="Notes">
    <QItemLabel>
      <QInput
        v-model="localRecordStore.record.note"
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
        @blur="localRecordStore.record.note = localRecordStore.record?.note?.trim()"
      >
        <template #append>
          <QIcon
            v-if="localRecordStore.record.note && localRecordStore.record.note !== ''"
            class="cursor-pointer"
            :name="cancelIcon"
            @click="localRecordStore.record.note = ''"
          />
        </template>
      </QInput>
    </QItemLabel>
  </DialogFormSharedItem>
</template>
