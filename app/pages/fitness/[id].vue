<script setup lang="ts">
import { DialogConfirm } from '#components'
import { appTitle, cancelIcon, saveIcon } from '#shared/constants'
import { getActiveWorkoutResponseSchema } from '#shared/types/fitness-schemas'

useMeta({ title: `${appTitle} | Fitness - Active Workout` })

type Exercise = {
  name: string
  description: string
  rest_timer: number
  checklist: string[]
}

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

    const { data, error } = await supabase.rpc('get_active_workout')
    if (error) throw error

    const typedData: GetActiveWorkoutResponse = data as GetActiveWorkoutResponse

    if (typeof typedData.workout_result.exercise_results === 'string') {
      typedData.workout_result.exercise_results = JSON.parse(
        typedData.workout_result.exercise_results,
      )
    } else if (!typedData.workout_result.exercise_results) {
      typedData.workout_result.exercise_results = []
    }

    if (typeof typedData.workout.exercises === 'string') {
      typedData.workout.exercises = JSON.parse(typedData.workout.exercises)
    } else if (!typedData.workout.exercises) {
      typedData.workout.exercises = []
    }

    // Ensure exercise_results is initialized with correct structure
    if (
      !Array.isArray(typedData.workout_result.exercise_results) ||
      typedData.workout_result.exercise_results.length !==
        (Array.isArray(typedData.workout.exercises) ? typedData.workout.exercises.length : 0)
    ) {
      typedData.workout_result.exercise_results = (typedData.workout.exercises as Exercise[]).map(
        (ex) => ({
          note: '',
          checked: Array.isArray(ex.checklist) ? ex.checklist.map(() => false) : [false],
        }),
      )
    }

    const res = getActiveWorkoutResponseSchema.parse(data)

    workoutStore.workout = res.workout
    workoutStore.workoutResult = res.workout_result
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

        await onUpdateActiveWorkout()

        const { error } = await supabase.rpc('finish_active_workout', {
          w_id: workoutId as string,
          wr_note: workoutStore.workoutResult?.note || '',
          wr_exercise_results: JSON.stringify(workoutStore.workoutResult?.exercise_results || []),
        })
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

async function onUpdateActiveWorkout() {
  try {
    $q.loading.show()

    const { error: updateError } = await supabase
      .from('workout_results')
      .update({
        note: workoutStore.workoutResult.note,
        exercise_results: JSON.stringify(workoutStore.workoutResult.exercise_results),
      })
      .eq('id', workoutStore.workoutResult.id)
    if (updateError) throw updateError
  } catch (error) {
    logger.error('Error updating active workout', error as Error)
  } finally {
    $q.loading.hide()
  }
}
</script>

<template>
  <QList padding>
    <QCard v-if="workoutStore.workout.description" flat bordered class="q-mb-md">
      <QItem>
        <QItemSection>
          <QItemLabel class="text-body1">Workout Description</QItemLabel>
          <QItemLabel caption>
            {{ workoutStore.workout.description }}
          </QItemLabel>
        </QItemSection>
      </QItem>
    </QCard>

    <div v-for="(exercise, exIdx) in workoutStore.workout.exercises" :key="exIdx">
      <QCard flat bordered class="q-mt-md">
        <QItem>
          <QItemSection>
            <QItemLabel class="text-body1">{{ exercise.name }}</QItemLabel>
            <QItemLabel v-if="exercise.description" caption>
              {{ exercise.description }}
            </QItemLabel>
          </QItemSection>
        </QItem>
      </QCard>

      <QItem>
        <QItemSection>
          <QCheckbox
            v-for="(item, itemIdx) in exercise.checklist"
            :key="itemIdx"
            v-model="workoutStore.workoutResult.exercise_results[exIdx].checked[itemIdx]"
            :label="item"
            :disable="!workoutStore.workoutResult.exercise_results[exIdx]"
            @blur="onUpdateActiveWorkout()"
          />
        </QItemSection>
      </QItem>

      <QItem>
        <QItemSection>
          <QItemLabel>
            <QInput
              v-model="workoutStore.workoutResult.exercise_results[exIdx].note"
              :rules="[
                (val: string) =>
                  !val ||
                  val.length <= limitRuleLookup.maxTextArea ||
                  `Notes cannot exceed ${limitRuleLookup.maxTextArea} characters`,
              ]"
              :maxlength="limitRuleLookup.maxTextArea"
              type="textarea"
              lazy-rules
              autogrow
              counter
              dense
              outlined
              color="primary"
              :label="`${exercise.name} Notes`"
              @blur="
                ((workoutStore.workoutResult.exercise_results[exIdx].note =
                  workoutStore.workoutResult.exercise_results[exIdx].note?.trim()),
                onUpdateActiveWorkout())
              "
            >
              <template #append>
                <QIcon
                  v-if="
                    workoutStore.workoutResult.exercise_results[exIdx].note &&
                    workoutStore.workoutResult.exercise_results[exIdx].note !== ''
                  "
                  class="cursor-pointer"
                  :name="cancelIcon"
                  @click="workoutStore.workoutResult.exercise_results[exIdx].note = ''"
                />
              </template>
            </QInput>
          </QItemLabel>
        </QItemSection>
      </QItem>
    </div>

    <QSeparator class="q-my-md" />

    <QItem>
      <QItemSection>
        <QItemLabel>
          <QInput
            v-model="workoutStore.workoutResult.note"
            :rules="[
              (val: string) =>
                !val ||
                val.length <= limitRuleLookup.maxTextArea ||
                `Notes cannot exceed ${limitRuleLookup.maxTextArea} characters`,
            ]"
            :maxlength="limitRuleLookup.maxTextArea"
            type="textarea"
            lazy-rules
            autogrow
            counter
            dense
            outlined
            :label="`${workoutStore.workout.name} Notes`"
            color="primary"
            @blur="
              ((workoutStore.workoutResult.note = workoutStore.workoutResult.note?.trim()),
              onUpdateActiveWorkout())
            "
          >
            <template #append>
              <QIcon
                v-if="workoutStore.workoutResult.note && workoutStore.workoutResult.note !== ''"
                class="cursor-pointer"
                :name="cancelIcon"
                @click="workoutStore.workoutResult.note = ''"
              />
            </template>
          </QInput>
        </QItemLabel>
      </QItemSection>
    </QItem>

    <div class="row justify-center">
      <QBtn label="Finish Workout" :icon="saveIcon" color="positive" @click="onFinished" />
    </div>
  </QList>
</template>
