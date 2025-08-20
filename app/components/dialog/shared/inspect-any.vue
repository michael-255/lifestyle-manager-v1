<script setup lang="ts">
defineProps<{
  label: string
  value: any
}>()
</script>

<template>
  <DialogSharedBaseItemInspect :label="label">
    {{ value }}
  </DialogSharedBaseItemInspect>
</template>
