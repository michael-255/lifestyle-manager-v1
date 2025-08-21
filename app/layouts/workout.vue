<script setup lang="ts">
import { closeIcon } from '#shared/constants'

const workoutStore = useWorkoutStore()
</script>

<template>
  <QLayout view="hHh lpr lfr">
    <QHeader bordered>
      <QToolbar class="toolbar-height">
        <QToolbarTitle>{{ workoutStore.name }}</QToolbarTitle>
        <QBtn flat round :icon="closeIcon" to="/fitness" />
      </QToolbar>
    </QHeader>

    <LayoutContainer />
  </QLayout>
</template>

<style scoped>
.toolbar-height {
  height: 3.25rem;
}
</style>
