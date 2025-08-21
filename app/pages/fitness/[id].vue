<script setup lang="ts">
import { DialogConfirm } from '#components'
import { appTitle, saveIcon } from '#shared/constants'
import { getActiveWorkoutResponseSchema } from '#shared/types/fitness-schemas'

useMeta({ title: `${appTitle} | Fitness - Active Workout` })

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()
const workoutStore = useWorkoutStore()
const route = useRoute()
const router = useRouter()

const workoutId = route.params.id

definePageMeta({
  layout: 'workout',
})

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase.rpc('get_active_workout', { w_id: workoutId as IdType })
    if (error) throw error

    const res = getActiveWorkoutResponseSchema.parse(data)

    workoutStore.name = res.workout.name
  } catch (error) {
    logger.error('Error starting active workout', error as Error)
    router.push('/fitness')
  } finally {
    $q.loading.hide()
  }
})

onUnmounted(() => {
  workoutStore.$reset()
})

async function onFinished() {
  try {
    $q.dialog({
      component: DialogConfirm,
      componentProps: {
        title: 'Finish Workout',
        message: `Are you sure you want to finish this workout?`,
        color: 'positive',
        icon: saveIcon,
        requiresUnlock: false,
      },
    }).onOk(async () => {
      try {
        $q.loading.show()

        const { error } = await supabase.rpc('finish_workout', { w_id: workoutId as IdType })
        if (error) throw error

        router.push('/fitness')
      } catch (error) {
        logger.error('Error finishing workout', error as Error)
      } finally {
        $q.loading.hide()
      }
    })
  } catch (error) {
    logger.error('Error opening finish workout dialog', error as Error)
  }
}
</script>

<template>
  <QList padding>
    {{ workoutId }}
    <QItem>
      <QItemSection>
        <QItemLabel>
          <div class="row justify-center">
            <QBtn label="Finish Workout" :icon="saveIcon" color="positive" @click="onFinished" />
          </div>
        </QItemLabel>
      </QItemSection>
    </QItem>
  </QList>
</template>
