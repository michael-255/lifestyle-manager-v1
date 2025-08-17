<script setup lang="ts">
defineProps<{
  log: Record<string, any>
}>()
</script>

<template>
  <DialogInspectSharedItemText label="Auto Id" :value="log.autoId" />
  <DialogInspectSharedItemDate label="Created Date" :value="log.created_at" />
  <DialogInspectSharedItemText label="Log Level" :value="log.log_level" />
  <DialogInspectSharedItemText label="Label" :value="log.label" />
  <DialogInspectSharedItemObject label="Details" :value="log.details" />
</template>
