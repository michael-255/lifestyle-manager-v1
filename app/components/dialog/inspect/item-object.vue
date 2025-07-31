<script setup lang="ts">
defineProps<{
  label: string
  value?: Record<string, any>
}>()
</script>

<template>
  <DialogInspectItem :label="label">
    <div v-if="value && Object.keys(value).length > 0">
      <div v-for="(v, k) in value" :key="k">
        <span class="text-amber">{{ k }}:</span> {{ v }}
      </div>
    </div>
    <div v-else class="text-italic text-secondary">-empty-</div>
  </DialogInspectItem>
</template>
