<script setup lang="ts">
import { Constants } from '#shared/types/supabase'
import { computed } from 'vue'

const localRecordStore = useLocalRecordStore()

const exerciseTypeOptions = Constants.public.Enums.exercise_type

const half = Math.ceil(exerciseTypeOptions.length / 2)
const exerciseTypeCols = [exerciseTypeOptions.slice(0, half), exerciseTypeOptions.slice(half)]

const exerciseType = computed({
  get: () => localRecordStore.record.type || 'Checklist',
  set: (val) => (localRecordStore.record.type = val),
})
</script>

<template>
  <DialogFormItem label="Exercise Type">
    <QItemLabel>
      <div class="row">
        <div class="col column">
          <QRadio
            v-for="option in exerciseTypeCols[0]"
            :key="option"
            v-model="exerciseType"
            :val="option"
            :label="option"
            color="primary"
          />
        </div>
        <div class="col column">
          <QRadio
            v-for="option in exerciseTypeCols[1]"
            :key="option"
            v-model="exerciseType"
            :val="option"
            :label="option"
            color="primary"
          />
        </div>
      </div>
    </QItemLabel>
  </DialogFormItem>
</template>
