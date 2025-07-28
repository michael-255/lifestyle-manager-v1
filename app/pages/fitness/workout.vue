<script setup lang="ts">
import { appTitle } from '#shared/constants'

useMeta({ title: `${appTitle} | Fitness - Workout` })

definePageMeta({
  layout: 'workout',
})
</script>

<template>
  <SharedHeading title="Workout" />

  <QList padding> Workout </QList>
</template>
