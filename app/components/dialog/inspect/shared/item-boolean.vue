<script setup lang="ts">
defineProps<{
  label: string
  value?: boolean
}>()
</script>

<template>
  <DialogInspectSharedItem :label="label">
    <div v-if="value === true">Yes</div>
    <div v-else-if="value === false">No</div>
    <div v-else class="text-italic text-secondary">empty</div>
  </DialogInspectSharedItem>
</template>
