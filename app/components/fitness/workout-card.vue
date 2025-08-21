<script setup lang="ts">
import {
  cardMenuIcon,
  chartsIcon,
  deleteIcon,
  editIcon,
  inspectIcon,
  noteIcon,
  startIcon,
} from '#shared/constants'
import type { TodaysWorkout } from '#shared/types/fitness-schemas'

defineProps<{
  todaysWorkout: TodaysWorkout
}>()

const router = useRouter()
const { openInspectWorkout, openEditWorkout, openDeleteWorkout } = useFitnessDialogs()

function onCharts() {
  console.log('Charts clicked')
}

async function onStart(id: IdType) {
  console.log('Start Workout clicked')
  router.push(`/fitness/${id}`)
}

// async function onResume(id: IdType) {
//   console.log('Resume Workout clicked')
//   router.push(`/fitness/${id}`)
// }
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

                  <QItem clickable @click="openEditWorkout(todaysWorkout.id!)">
                    <QItemSection avatar>
                      <QIcon color="amber" :name="editIcon" />
                    </QItemSection>

                    <QItemSection>Edit</QItemSection>
                  </QItem>

                  <QItem clickable @click="openDeleteWorkout(todaysWorkout.id!)">
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
            <QBtn
              class="full-width q-mb-sm"
              :icon="startIcon"
              label="Start Workout"
              color="primary"
              @click="onStart(todaysWorkout.id!)"
            />
          </QItemSection>
        </QItem>
      </QCard>
    </QItemSection>
  </QItem>
</template>
