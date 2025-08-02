<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  label: string
  value?: string | number | boolean
}>()

const computedValue = computed(() => {
  if (typeof props.value === 'string' && props.value.includes('\n')) {
    return props.value.split('\n')
  }
  return props.value
})
</script>

<template>
  <DialogInspectItem :label="label">
    <div v-if="value === true">Yes</div>
    <div v-else-if="value === false">No</div>
    <div v-else-if="Array.isArray(computedValue)">
      <div v-for="line in computedValue" :key="line">{{ line }}<br /></div>
    </div>
    <div v-else-if="value">{{ value }}</div>
    <div v-else class="text-italic text-secondary">empty</div>
  </DialogInspectItem>
</template>
