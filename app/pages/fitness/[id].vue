<script setup lang="ts">
import { appTitle } from '#shared/constants'

useMeta({ title: `${appTitle} | Fitness - Active Workout` })

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()
const workoutStore = useWorkoutStore()
const route = useRoute()

const workoutId = route.params.id

definePageMeta({
  layout: 'workout',
})

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase.rpc('get_active_workout', { w_id: workoutId as IdType })
    if (error) throw error

    logger.info('Active workout data:', data)

    workoutStore.name = data.workout.name

    // Getting the active workout and exercises, and workout results and exercise results
    // TODO
  } catch (error) {
    logger.error('Error starting active workout', error as Error)
  } finally {
    $q.loading.hide()
  }
})

// TODO:
// Get workout and exercise data from DB
// Set
</script>

<template>
  <QList padding> {{ workoutId }} </QList>
</template>
