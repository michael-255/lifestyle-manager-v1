<script setup lang="ts">
import { cancelIcon } from '#shared/constants'
import { limitRuleLookup } from '#shared/utils/utils'

const localRecordStore = useLocalRecordStore()
</script>

<template>
  <DialogSharedBaseItemForm label="Name">
    <QItemLabel>
      <QInput
        v-model="localRecordStore.record.name"
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
        @blur="localRecordStore.record.name = localRecordStore.record?.name?.trim()"
      >
        <template #append>
          <QIcon
            v-if="localRecordStore.record.name && localRecordStore.record.name !== ''"
            class="cursor-pointer"
            :name="cancelIcon"
            @click="localRecordStore.record.name = ''"
          />
        </template>
      </QInput>
    </QItemLabel>
  </DialogSharedBaseItemForm>
</template>
