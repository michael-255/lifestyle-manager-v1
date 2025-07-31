<script setup lang="ts">
import { DialogInspectItem } from '#components'

defineProps<{
  label: string
  value: any
}>()
</script>

<template>
  <DialogInspectItem :label="label">
    {{ value }}
  </DialogInspectItem>
</template>
