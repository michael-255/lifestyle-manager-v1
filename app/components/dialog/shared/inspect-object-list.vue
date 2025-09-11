<script setup lang="ts">
const props = defineProps<{
  label: string
  value?: Record<string, any>[] | string | null
}>()

const parsedValue = computed(() => {
  if (typeof props.value === 'string') {
    try {
      return JSON.parse(props.value)
    } catch {
      return null
    }
  }
  return props.value
})
</script>

<template>
  <DialogSharedBaseItemInspect :label="label">
    <ul v-if="parsedValue && parsedValue.length > 0" class="q-pl-sm q-my-none">
      <li v-for="(obj, idx) in parsedValue" :key="idx" class="q-ml-sm q-mb-sm">
        <div v-for="(v, k) in obj" :key="k">
          <span class="text-amber">{{ k }}:</span> {{ v }}
        </div>
      </li>
    </ul>
    <div v-else class="text-italic text-secondary">empty</div>
  </DialogSharedBaseItemInspect>
</template>
