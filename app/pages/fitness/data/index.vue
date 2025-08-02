<script setup lang="ts">
import { addIcon, appTitle, databaseIcon } from '#shared/constants'
import { recordCount } from '#shared/utils/utils'

useMeta({ title: `${appTitle} | Fitness - Data Management` })

definePageMeta({
  layout: 'fitness',
})

const router = useRouter()
const { openCreateWorkout, openCreateWorkoutResult, openCreateExercise, openCreateExerciseResult } =
  useFitnessDialogs()
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
              <QItemLabel caption>{{ recordCount(11) }}</QItemLabel>
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
              <QItemLabel caption>{{ recordCount(111) }}</QItemLabel>
            </QItemSection>

            <QItemSection top side>
              <QBtn
                :icon="addIcon"
                color="positive"
                class="q-px-sm q-mb-sm"
                @click="openCreateWorkoutResult"
              />
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
              <QItemLabel caption>{{ recordCount(11) }}</QItemLabel>
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
              <QItemLabel caption>{{ recordCount(111) }}</QItemLabel>
            </QItemSection>

            <QItemSection top side>
              <QBtn
                :icon="addIcon"
                color="positive"
                class="q-px-sm q-mb-sm"
                @click="openCreateExerciseResult"
              />
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
