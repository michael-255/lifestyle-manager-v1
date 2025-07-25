<script setup lang="ts">
import { appTitle } from '#shared/constants'

useMeta({ title: `${appTitle} | Fitness Data` })

definePageMeta({
  layout: 'fitness',
})
</script>

<template>
  <SharedHeading title="Data" />

  <QList padding>
    <div v-for="i in 100" :key="i">
      Lorem ipsum dolor sit amet consectetur adipisicing elit. Inventore ad, laboriosam odit quae
      est quo. Molestias numquam nihil quisquam inventore, quasi dolores accusantium, ullam odio
      fugiat officia magni neque voluptatibus.
    </div>
  </QList>
</template>
