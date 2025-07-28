<script setup lang="ts">
import { addIcon, appTitle, databaseIcon } from '#shared/constants'
import { recordCount } from '#shared/utils/utils'

useMeta({ title: `${appTitle} | Fitness - Data Management` })

definePageMeta({
  layout: 'fitness',
})

const router = useRouter()

function onCreateWorkout() {
  console.log('Create Workout')
}

function onCreateWorkoutResult() {
  console.log('Create Workout Result')
}

function onCreateExercise() {
  console.log('Create Exercise')
}

function onCreateExerciseResult() {
  console.log('Create Exercise Result')
}
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
                @click="onCreateWorkout"
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
                @click="onCreateWorkoutResult"
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
                @click="onCreateExercise"
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
                @click="onCreateExerciseResult"
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
