<script setup lang="ts">
defineProps<{
  label: string
  value?: any[] | null
}>()
</script>

<template>
  <DialogSharedBaseItemInspect :label="label">
    <ul v-if="value && value?.length > 0" class="q-pl-sm q-my-none">
      <li v-for="x in value" :key="x" class="q-ml-sm q-mb-xs">
        {{ x }}
      </li>
    </ul>
    <div v-else class="text-italic text-secondary">empty</div>
  </DialogSharedBaseItemInspect>
</template>
