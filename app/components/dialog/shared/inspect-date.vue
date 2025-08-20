<script setup lang="ts">
defineProps<{
  label: string
  value?: string
}>()
</script>

<template>
  <DialogSharedBaseItemInspect :label="label">
    <div v-if="value">
      {{ localDisplayDate(value) }}
    </div>
    <div v-else class="text-italic text-secondary">empty</div>
  </DialogSharedBaseItemInspect>
</template>
