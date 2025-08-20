<script setup lang="ts">
defineProps<{
  log: LogType
}>()
</script>

<template>
  <DialogInspect label="Log" :is-loading="false">
    <DialogSharedInspectText label="Auto Id" :value="log.autoId" />
    <DialogSharedInspectDate label="Created Date" :value="log.created_at" />
    <DialogSharedInspectText label="Log Level" :value="log.log_level" />
    <DialogSharedInspectText label="Label" :value="log.label" />
    <DialogSharedInspectObject label="Details" :value="log.details!" />
  </DialogInspect>
</template>
