<script setup lang="ts">
import { compactDate } from '#shared/utils/utils'
import { computed } from 'vue'

const props = defineProps<{
  label: string
  field: string
  record: Record<string, any>
}>()

const value = computed(() => {
  return props.record[props.field]
})
</script>

<template>
  <DialogInspectItem :label="label">
    <div v-if="value">
      {{ compactDate(value) }}
    </div>

    <div v-else class="text-italic text-secondary">-empty-</div>
  </DialogInspectItem>
</template>
