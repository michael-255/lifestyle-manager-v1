<script setup lang="ts">
defineProps<{
  setting: SettingType
}>()
</script>

<template>
  <DialogInspect label="Setting" :is-loading="false">
    <DialogSharedInspectText label="Key" :value="setting.key" />
    <DialogSharedInspectText label="Value" :value="setting.value" />
  </DialogInspect>
</template>
