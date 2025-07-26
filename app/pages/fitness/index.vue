<script setup lang="ts">
import { appTitle } from '#shared/constants'

useMeta({ title: `${appTitle} | Fitness: Today's Plan` })

definePageMeta({
  layout: 'fitness',
})
const recordsList = [
  {
    id: 1,
    name: 'Barbell Strength - A',
    last_created_at: new Date().toISOString(),
    scheduled: ['Monday', 'Wednesday', 'Friday'],
  },
  {
    id: 2,
    name: 'Warmup & Posture',
    last_created_at: new Date().toISOString(),
    scheduled: ['Daily'],
  },
]

const records = ref(recordsList)
</script>

<template>
  <SharedHeading title="Today's Plan" />

  <QList padding>
    <div v-if="records.length === 0">
      <QItem>
        <QItemSection>
          <QCard flat bordered>
            <QItem class="q-my-sm q-pa-lg text-center">
              <QItemSection>
                <QItemLabel class="text-body1">Rest Day</QItemLabel>
                <QItemLabel caption class="text-italic">No workouts scheduled</QItemLabel>
              </QItemSection>
            </QItem>
          </QCard>
        </QItemSection>
      </QItem>
    </div>

    <div v-else>
      <FitnessPlanCard v-for="record in records" :key="record.id" :record="record" />
    </div>
  </QList>
</template>
