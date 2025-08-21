<script setup lang="ts">
import { cancelIcon } from '#shared/constants'
import { limitRuleLookup } from '#shared/utils/utils'

const recordStore = useRecordStore()
</script>

<template>
  <DialogSharedBaseItemForm label="Description">
    <QItemLabel>
      <QInput
        v-model="recordStore.record.description"
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
        @blur="recordStore.record.description = recordStore.record?.description?.trim()"
      >
        <template #append>
          <QIcon
            v-if="recordStore.record.description && recordStore.record.description !== ''"
            class="cursor-pointer"
            :name="cancelIcon"
            @click="recordStore.record.description = ''"
          />
        </template>
      </QInput>
    </QItemLabel>
  </DialogSharedBaseItemForm>
</template>
