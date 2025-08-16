<script setup lang="ts">
import { addIcon, appTitle, databaseIcon } from '#shared/constants'
import { recordCount } from '#shared/utils/utils'

useMeta({ title: `${appTitle} | Fitness - Data Management` })

definePageMeta({
  layout: 'fitness',
})

const $q = useQuasar()
const logger = useLogger()
const router = useRouter()
const supabase = useSupabaseClient<Database>()
const { openCreateWorkout, openCreateExercise } = useFitnessDialogs()

const tableCounts = ref({
  workouts: 0,
  exercises: 0,
  workoutResults: 0,
  exerciseResults: 0,
})

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase.from('table_counts').select().single()
    if (error) throw error

    tableCounts.value = {
      workouts: data.workouts ?? 0,
      exercises: data.exercises ?? 0,
      workoutResults: data.workout_results ?? 0,
      exerciseResults: data.exercise_results ?? 0,
    }
  } catch (error) {
    logger.error(`Error fetching table counts`, error as Error)
  } finally {
    $q.loading.hide()
  }
})
</script>

<template>
  <SharedHeading title="Data Management" />

  <QList padding>
    <QItem>
      <QItemSection>
        <QCard flat bordered>
          <QItem class="q-mt-sm">
            <QItemSection top>
              <QItemLabel class="text-body1">Workouts</QItemLabel>
              <QItemLabel caption>{{ recordCount(tableCounts.workouts) }}</QItemLabel>
            </QItemSection>

            <QItemSection top side>
              <QBtn
                :icon="addIcon"
                color="positive"
                class="q-px-sm q-mb-sm"
                @click="openCreateWorkout"
              />
            </QItemSection>

            <QItemSection top side>
              <QBtn
                :icon="databaseIcon"
                color="primary"
                class="q-px-sm q-mb-sm"
                @click="router.push('/fitness/data/workouts')"
              />
            </QItemSection>
          </QItem>

          <QItem>
            <QItemSection top>
              <QItemLabel class="text-body1">Results</QItemLabel>
              <QItemLabel caption>{{ recordCount(tableCounts.workoutResults) }}</QItemLabel>
            </QItemSection>

            <QItemSection top side>
              <QBtn
                :icon="databaseIcon"
                color="primary"
                class="q-px-sm q-mb-sm"
                @click="router.push('/fitness/data/workout-results')"
              />
            </QItemSection>
          </QItem>
        </QCard>
      </QItemSection>
    </QItem>

    <QItem>
      <QItemSection>
        <QCard flat bordered>
          <QItem class="q-mt-sm">
            <QItemSection top>
              <QItemLabel class="text-body1">Exercises</QItemLabel>
              <QItemLabel caption>{{ recordCount(tableCounts.exercises) }}</QItemLabel>
            </QItemSection>

            <QItemSection top side>
              <QBtn
                :icon="addIcon"
                color="positive"
                class="q-px-sm q-mb-sm"
                @click="openCreateExercise"
              />
            </QItemSection>

            <QItemSection top side>
              <QBtn
                :icon="databaseIcon"
                color="primary"
                class="q-px-sm q-mb-sm"
                @click="router.push('/fitness/data/exercises')"
              />
            </QItemSection>
          </QItem>

          <QItem>
            <QItemSection top>
              <QItemLabel class="text-body1">Results</QItemLabel>
              <QItemLabel caption>{{ recordCount(tableCounts.exerciseResults) }}</QItemLabel>
            </QItemSection>

            <QItemSection top side>
              <QBtn
                :icon="databaseIcon"
                color="primary"
                class="q-px-sm q-mb-sm"
                @click="router.push('/fitness/data/exercise-results')"
              />
            </QItemSection>
          </QItem>
        </QCard>
      </QItemSection>
    </QItem>
  </QList>
</template>
