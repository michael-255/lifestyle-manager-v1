<script setup lang="ts">
defineProps<{
  label: string
  value?: Record<string, any>[] | null
}>()
</script>

<template>
  <DialogSharedBaseItemInspect :label="label">
    <ul v-if="value && value.length > 0" class="q-pl-sm q-my-none">
      <li v-for="(obj, idx) in value" :key="idx" class="q-ml-sm q-mb-sm">
        <div v-for="(v, k) in obj" :key="k">
          <span class="text-amber">{{ k }}:</span> {{ v }}
        </div>
      </li>
    </ul>
    <div v-else class="text-italic text-secondary">empty</div>
  </DialogSharedBaseItemInspect>
</template>
