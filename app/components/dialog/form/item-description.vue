<script setup lang="ts">
import { cancelIcon } from '#shared/constants'
import { limitRuleLookup } from '#shared/utils/utils'

const localRecordStore = useLocalRecordStore()
</script>

<template>
  <DialogFormItem label="Description">
    <QItemLabel>
      <QInput
        v-model="localRecordStore.record.description"
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
        @blur="localRecordStore.record.description = localRecordStore.record?.description?.trim()"
      >
        <template #append>
          <QIcon
            v-if="localRecordStore.record.description && localRecordStore.record.description !== ''"
            class="cursor-pointer"
            :name="cancelIcon"
            @click="localRecordStore.record.description = ''"
          />
        </template>
      </QInput>
    </QItemLabel>
  </DialogFormItem>
</template>
