<script setup lang="ts">
import { Constants } from '#shared/types/supabase'

const localRecordStore = useLocalRecordStore()

const options = Constants.public.Enums.exercise_type
</script>

<template>
  <DialogSharedBaseItemForm label="Exercise Type">
    <QItemLabel v-if="localRecordStore.action === 'EDIT'">
      <span class="text-body2">
        {{ localRecordStore.record.type }}
      </span>
    </QItemLabel>

    <QItemLabel v-else>
      <QSelect
        v-model="localRecordStore.record.type"
        :options="options"
        :rules="[(val) => !!val || 'Required']"
        lazy-rules
        emit-value
        map-options
        options-dense
        dense
        outlined
        color="primary"
      />
    </QItemLabel>
  </DialogSharedBaseItemForm>
</template>
