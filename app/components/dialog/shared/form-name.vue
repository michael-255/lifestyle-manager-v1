<script setup lang="ts">
import { cancelIcon } from '#shared/constants'
import { limitRuleLookup } from '#shared/utils/utils'

const recordStore = useRecordStore()
</script>

<template>
  <DialogSharedBaseItemForm label="Name">
    <QItemLabel>
      <QInput
        v-model="recordStore.record.name"
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
        @blur="recordStore.record.name = recordStore.record?.name?.trim()"
      >
        <template #append>
          <QIcon
            v-if="recordStore.record.name && recordStore.record.name !== ''"
            class="cursor-pointer"
            :name="cancelIcon"
            @click="recordStore.record.name = ''"
          />
        </template>
      </QInput>
    </QItemLabel>
  </DialogSharedBaseItemForm>
</template>
