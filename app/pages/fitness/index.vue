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
const hasActiveInList = ref(false)
const finishedLoading = ref(false)

const channel = supabase
  .channel('public.workouts')
  .on('postgres_changes', { event: '*', schema: 'public', table: 'workouts' }, async () => {
    await getTodaysWorkouts()
  })
  .subscribe()

onMounted(async () => {
  await getTodaysWorkouts()
})

onUnmounted(() => {
  if (channel) {
    supabase.removeChannel(channel)
  }
})

async function getTodaysWorkouts() {
  try {
    $q.loading.show()

    const { data, error } = await supabase.from('todays_workouts').select()
    if (error) throw error

    // Determine which workouts were completed today based on last_created_at
    const todaysData = data.map((workout) => {
      if (workout.last_created_at) {
        const lastCreated = new Date(workout.last_created_at)
        const now = new Date()
        const isSameDay =
          lastCreated.getFullYear() === now.getFullYear() &&
          lastCreated.getMonth() === now.getMonth() &&
          lastCreated.getDate() === now.getDate()
        return { ...workout, is_completed: isSameDay }
      }
      return { ...workout, is_completed: false }
    })

    todaysWorkouts.value = todaysData
    hasActiveInList.value = todaysWorkouts.value.some((workout) => workout.is_active)
  } catch (error) {
    logger.error(`Error fetching today's workouts`, error as Error)
  } finally {
    finishedLoading.value = true
    $q.loading.hide()
  }
}
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
        :has-active-in-list
      />
    </div>
  </QList>
</template>
