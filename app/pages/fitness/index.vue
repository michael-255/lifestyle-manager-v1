<script setup lang="ts">
import { appTitle } from '#shared/constants'

useMeta({ title: `${appTitle} | Fitness: Today's Plan` })

definePageMeta({
  layout: 'fitness',
})

const supabase = useSupabaseClient()

const recordsList = [
  {
    id: 1,
    name: 'Barbell Strength - A',
    last_created_at: new Date().toISOString(),
    schedule: ['Monday', 'Wednesday', 'Friday'],
  },
  {
    id: 2,
    name: 'Warmup & Posture',
    last_created_at: new Date().toISOString(),
    last_note: 'Focus on hip mobility and shoulder stability.',
    schedule: ['Daily'],
  },
]

const records = ref(recordsList)

async function onTest() {
  const { data, error } = await supabase.from('exercises').insert({
    user_id: useSupabaseUser().value?.id,
    created_at: new Date().toISOString(),
    name: 'Test Exercise',
    description: 'This is a test exercise.',
    type: 'Weightlifting',
  })

  if (error) {
    console.error('Error inserting test exercise:', error)
  } else {
    console.log('Test exercise inserted:', data)
    // Optionally, you can refresh the records or show a success message
  }
}
</script>

<template>
  <SharedHeading title="Today's Plan">
    <QBtn icon="add" label="Test" color="accent" @click="onTest" />
  </SharedHeading>

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
