<script setup lang="ts">
import { appTitle } from '#shared/constants'
import type { Database } from '#shared/types/supabase'

useMeta({ title: `${appTitle} | Fitness - Today's Plan` })

definePageMeta({
  layout: 'fitness',
})

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()

// TODO - fix type
const workouts = ref<Record<string, any>[]>([])
const finishedLoading = ref(false)

onMounted(async () => {
  try {
    $q.loading.show()

    // TODO - Move this to the data-layer?
    const { data, error } = await supabase
      .from('todays_workouts')
      .select('*')
      .order('name', { ascending: true })

    if (error) throw error

    logger.info("Successfully fetched today's workouts", { count: data.length })
    workouts.value = data
  } catch (error) {
    logger.error(`Error fetching today's workouts`, error as Error)
  } finally {
    finishedLoading.value = true
    $q.loading.hide()
  }
})
</script>

<template>
  <SharedHeading title="Today's Plan" />

  <QList padding>
    <div v-if="finishedLoading && workouts.length === 0">
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
      <FitnessWorkoutCard v-for="workout in workouts" :key="workout.id" :workout />
    </div>
  </QList>
</template>
