<script setup lang="ts">
defineProps<{
  label: string
  value: any
}>()
</script>

<template>
  <DialogInspectSharedItem :label="label">
    {{ value }}
  </DialogInspectSharedItem>
</template>
