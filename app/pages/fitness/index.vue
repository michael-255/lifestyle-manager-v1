<script setup lang="ts">
import { appTitle } from '#shared/constants'
import type { TodaysWorkout } from '#shared/types/fitness-schemas'
import type { Database } from '#shared/types/supabase'

useMeta({ title: `${appTitle} | Fitness - Today's Plan` })

definePageMeta({
  layout: 'fitness',
})

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()

const todaysWorkouts = ref<TodaysWorkout[]>([])
const finishedLoading = ref(false)

// TODO: Need a better setup for realtime data updates
const channel = supabase
  .channel('public.workouts')
  .on('postgres_changes', { event: '*', schema: 'public', table: 'workouts' }, async () => {
    const { data, error } = await supabase.from('todays_workouts').select()
    if (error) throw error

    todaysWorkouts.value = data
  })
  .subscribe()

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase.from('todays_workouts').select()

    if (error) throw error

    todaysWorkouts.value = data
  } catch (error) {
    logger.error(`Error fetching today's workouts`, error as Error)
  } finally {
    finishedLoading.value = true
    $q.loading.hide()
  }
})

onUnmounted(() => {
  if (channel) {
    supabase.removeChannel(channel)
  }
})
</script>

<template>
  <SharedHeading title="Today's Plan" />

  <QList padding>
    <div v-if="finishedLoading && todaysWorkouts.length === 0">
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
      <FitnessWorkoutCard
        v-for="workout in todaysWorkouts"
        :key="workout.id!"
        :todays-workout="workout"
      />
    </div>
  </QList>
</template>
