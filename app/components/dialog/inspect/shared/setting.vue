<script setup lang="ts">
defineProps<{
  setting: Record<string, any>
}>()
</script>

<template>
  <DialogInspectSharedItemText label="Key" :value="setting.key" />
  <DialogInspectSharedItemText label="Value" :value="setting.value" />
</template>
