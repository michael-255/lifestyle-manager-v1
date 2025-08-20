<script setup lang="ts">
defineProps<{
  label: string
  value?: Record<string, any> | null
}>()
</script>

<template>
  <DialogSharedBaseItemInspect :label="label">
    <div v-if="value && Object.keys(value).length > 0">
      <div v-for="(v, k) in value" :key="k" class="q-mb-xs">
        <span class="text-amber">{{ k }}:</span> {{ v }}
      </div>
    </div>
    <div v-else class="text-italic text-secondary">empty</div>
  </DialogSharedBaseItemInspect>
</template>
