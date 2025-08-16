<script setup lang="ts">
import { Constants } from '#shared/types/supabase'

const localRecordStore = useLocalRecordStore()

const options = Constants.public.Enums.exercise_type
</script>

<template>
  <DialogFormItem label="Exercise Type">
    <QItemLabel>
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
  </DialogFormItem>
</template>
