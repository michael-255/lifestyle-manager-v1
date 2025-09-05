<script setup lang="ts">
import { DialogConfirm } from '#components'
import {
  cardMenuIcon,
  chartsIcon,
  completedIcon,
  deleteIcon,
  editIcon,
  inspectIcon,
  noteIcon,
  refreshIcon,
  startIcon,
} from '#shared/constants'
import type { TodaysWorkout } from '#shared/types/fitness-schemas'

defineProps<{
  todaysWorkout: TodaysWorkout
  hasActiveInList: boolean
}>()

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()
const router = useRouter()
const { openInspectWorkout, openEditWorkout, openDeleteWorkout } = useFitnessDialogs()

function onCharts() {
  console.log('Charts clicked')
}

async function onStart(id: IdType) {
  try {
    $q.loading.show()

    const { error } = await supabase.rpc('start_active_workout', { w_id: id })
    if (error) throw error

    router.push(`/fitness/${id}`)
  } catch (error) {
    logger.error('Error starting workout', error as Error)
  } finally {
    $q.loading.hide()
  }
}

async function onReplace(id: IdType) {
  try {
    $q.dialog({
      component: DialogConfirm,
      componentProps: {
        title: 'Replace Active Workout',
        message: `Are you sure you want to replace the active workout? This will delete any unsaved progress.`,
        color: 'warning',
        icon: refreshIcon,
        requiresUnlock: false,
      },
    }).onOk(async () => {
      try {
        $q.loading.show()

        const { error } = await supabase.rpc('replace_active_workout', { w_id: id })
        if (error) throw error

        router.push(`/fitness/${id}`)
      } catch (error) {
        logger.error('Error replacing active workout', error as Error)
      } finally {
        $q.loading.hide()
      }
    })
  } catch (error) {
    logger.error('Error opening replace active workout dialog', error as Error)
  }
}

async function onResume(id: IdType) {
  // Will get all the needed data on the workout page
  router.push(`/fitness/${id}`)
}

async function onCancel() {
  try {
    $q.dialog({
      component: DialogConfirm,
      componentProps: {
        title: 'Cancel Active Workout',
        message: `Are you sure you want to cancel the active workout? This will delete any unsaved progress.`,
        color: 'negative',
        icon: deleteIcon,
        requiresUnlock: false,
      },
    }).onOk(async () => {
      try {
        $q.loading.show()

        const { error } = await supabase.rpc('cancel_active_workout')
        if (error) throw error
      } catch (error) {
        logger.error('Error canceling active workout', error as Error)
      } finally {
        $q.loading.hide()
      }
    })
  } catch (error) {
    logger.error('Error opening cancel active workout dialog', error as Error)
  }
}
</script>

<template>
  <QItem>
    <QItemSection>
      <QCard flat bordered>
        <QItem class="q-mt-sm">
          <QItemSection top>
            <QItemLabel class="text-body1">{{ todaysWorkout.name }}</QItemLabel>

            <QItemLabel v-if="todaysWorkout.last_created_at" caption>
              <QBadge class="q-my-xs" outline :color="timeAgo(todaysWorkout.last_created_at).color">
                {{ timeAgo(todaysWorkout.last_created_at).message }}
              </QBadge>
              <div class="q-mt-xs">
                {{ localDisplayDate(todaysWorkout.last_created_at) }}
              </div>
            </QItemLabel>

            <QItemLabel v-else caption> No previous records </QItemLabel>
          </QItemSection>

          <QItemSection top side>
            <QBtn :icon="cardMenuIcon" flat round>
              <QMenu
                auto-close
                anchor="top right"
                transition-show="flip-right"
                transition-hide="flip-left"
              >
                <QList>
                  <QItem clickable :disable="!todaysWorkout.last_created_at" @click="onCharts">
                    <QItemSection avatar>
                      <QIcon
                        :color="!todaysWorkout.last_created_at ? 'grey' : 'cyan'"
                        :name="chartsIcon"
                      />
                    </QItemSection>

                    <QItemSection>Charts</QItemSection>
                  </QItem>

                  <QItem clickable @click="openInspectWorkout(todaysWorkout.id!)">
                    <QItemSection avatar>
                      <QIcon color="primary" :name="inspectIcon" />
                    </QItemSection>

                    <QItemSection>Inspect</QItemSection>
                  </QItem>

                  <QItem
                    clickable
                    :disable="!!todaysWorkout?.is_active"
                    @click="openEditWorkout(todaysWorkout.id!)"
                  >
                    <QItemSection avatar>
                      <QIcon color="amber" :name="editIcon" />
                    </QItemSection>

                    <QItemSection>Edit</QItemSection>
                  </QItem>

                  <QItem
                    clickable
                    :disable="!!todaysWorkout?.is_active"
                    @click="openDeleteWorkout(todaysWorkout.id!)"
                  >
                    <QItemSection avatar>
                      <QIcon color="negative" :name="deleteIcon" />
                    </QItemSection>

                    <QItemSection>Delete</QItemSection>
                  </QItem>
                </QList>
              </QMenu>
            </QBtn>
          </QItemSection>
        </QItem>

        <QItem v-if="todaysWorkout.last_note">
          <QItemSection>
            <QItemLabel>
              <QIcon size="xs" class="q-pb-xs" :name="noteIcon" />
              Previous Note
            </QItemLabel>
            <QItemLabel caption>
              <SharedUserText :text="todaysWorkout.last_note" />
            </QItemLabel>
          </QItemSection>
        </QItem>

        <QItem>
          <QItemSection>
            <div v-if="todaysWorkout.is_completed">
              <QBtn
                :icon="completedIcon"
                disable
                outline
                color="positive"
                class="full-width q-mb-sm"
                label="Completed"
              />
            </div>

            <div v-else-if="!!todaysWorkout?.is_active">
              <QBtn
                :icon="deleteIcon"
                color="negative"
                class="full-width q-mb-sm"
                label="Cancel Workout"
                @click="onCancel"
              />
              <QBtn
                class="full-width q-mb-sm"
                :icon="refreshIcon"
                label="Resume Workout"
                color="positive"
                @click="onResume(todaysWorkout.id!)"
              />
            </div>

            <div v-else>
              <QBtn
                v-if="hasActiveInList"
                class="full-width q-mb-sm"
                :icon="startIcon"
                label="Replace Workout"
                color="primary"
                @click="onReplace(todaysWorkout.id!)"
              />
              <QBtn
                v-else
                class="full-width q-mb-sm"
                :icon="startIcon"
                label="Start Workout"
                color="primary"
                @click="onStart(todaysWorkout.id!)"
              />
            </div>
          </QItemSection>
        </QItem>
      </QCard>
    </QItemSection>
  </QItem>
</template>
