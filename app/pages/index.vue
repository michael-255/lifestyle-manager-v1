<script setup lang="ts">
import { appTitle, fitnessIcon, settingsIcon } from '#shared/constants'
import { useMeta } from 'quasar'

useMeta({ title: `${appTitle} | Applications` })

const applicationButtons = [
  {
    label: 'Fitness',
    icon: fitnessIcon,
    color: 'primary',
    to: '/fitness',
  },
]
</script>

<template>
  <SharedHeading :title="appTitle">
    <QBtn flat round :icon="settingsIcon" to="/settings" />
  </SharedHeading>

  <div class="row q-col-gutter-md q-pa-sm">
    <div v-for="button in applicationButtons" :key="button.label" class="col-6">
      <QBtn
        class="application-btn full-width q-py-lg"
        stack
        glossy
        no-caps
        :color="button.color"
        :to="button.to"
      >
        <!-- <QBadge color="red" floating>7 </QBadge> -->
        <QIcon :name="button.icon" size="4rem" />
        <div class="q-mt-sm text-h6">
          {{ button.label }}
        </div>
      </QBtn>
    </div>
  </div>
</template>

<style scoped>
.application-btn {
  height: 9.5rem;
  border-radius: 1rem;
}
</style>
