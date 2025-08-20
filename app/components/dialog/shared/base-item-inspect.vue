<script setup lang="ts">
/**
 * Base item for inspect dialog content.
 */
defineProps<{
  label: string
}>()
</script>

<template>
  <QItem>
    <QItemSection>
      <QItemLabel>{{ label }}</QItemLabel>

      <QItemLabel caption>
        <slot />
      </QItemLabel>
    </QItemSection>
  </QItem>
</template>
