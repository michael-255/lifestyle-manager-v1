<script setup lang="ts">
import { closeIcon, timerIcon } from '#shared/constants'
import { onMounted, onUnmounted, ref } from 'vue'

const workoutStore = useWorkoutStore()

const elapsedTime = ref('')
let timer: number | undefined

const startTime = computed(() => {
  return workoutStore.workoutResult.created_at
    ? new Date(workoutStore.workoutResult.created_at).getTime()
    : Date.now()
})

function updateElapsedTime() {
  elapsedTime.value = timeFromDuration(Date.now() - startTime.value)
}

onMounted(() => {
  updateElapsedTime()
  timer = window.setInterval(updateElapsedTime, 1000)
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})
</script>

<template>
  <QLayout view="hHh lpr lfr">
    <QHeader bordered>
      <QToolbar class="toolbar-height">
        <QToolbarTitle>{{ workoutStore.workout.name }}</QToolbarTitle>
        <QBtn flat round :icon="closeIcon" to="/fitness" />
      </QToolbar>
    </QHeader>

    <LayoutContainer />

    <QFooter bordered>
      <QToolbar>
        <QSpace />
        <QIcon :name="timerIcon" size="sm" class="q-mr-sm" />
        <div class="text-h6">{{ elapsedTime }}</div>
        <QSpace />
      </QToolbar>
    </QFooter>
  </QLayout>
</template>

<style scoped>
.toolbar-height {
  height: 3.25rem;
}
</style>
