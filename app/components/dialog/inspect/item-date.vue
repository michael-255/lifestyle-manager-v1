<script setup lang="ts">
import { compactDate } from '#shared/utils/utils'

defineProps<{
  label: string
  value?: string
}>()
</script>

<template>
  <DialogInspectItem :label="label">
    <div v-if="value">
      {{ compactDate(value) }}
    </div>
    <div v-else class="text-italic text-secondary">-empty-</div>
  </DialogInspectItem>
</template>
