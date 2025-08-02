<script setup lang="ts">
defineProps<{
  label: string
  description?: string
}>()
</script>

<template>
  <QItem>
    <QItemSection>
      <QItemLabel class="text-body1">{{ label }}</QItemLabel>

      <QItemLabel v-if="description">
        {{ description }}
      </QItemLabel>

      <slot />
    </QItemSection>
  </QItem>
</template>
