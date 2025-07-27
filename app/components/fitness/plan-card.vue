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

defineProps<{
  record: Record<string, any>
}>()

function onCharts() {
  console.log('Charts clicked')
}

function onInspect() {
  console.log('Inspect clicked')
}

function onEdit() {
  console.log('Edit clicked')
}

function onDelete() {
  console.log('Delete clicked')
}

function onStart() {
  console.log('Start Workout clicked')
}
</script>

<template>
  <QItem>
    <QItemSection>
      <QCard flat bordered>
        <QItem class="q-mt-sm">
          <QItemSection top>
            <QItemLabel class="text-body1">{{ record.name }}</QItemLabel>

            <QItemLabel v-if="record.last_created_at" caption>
              <QBadge class="q-my-xs" outline :color="timeAgo(record.last_created_at).color">
                {{ timeAgo(record.last_created_at).message }}
              </QBadge>
              <div class="q-mt-xs">
                {{ compactDate(record.last_created_at) }}
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
                  <QItem clickable @click="onCharts">
                    <QItemSection avatar>
                      <QIcon color="cyan" :name="chartsIcon" />
                    </QItemSection>

                    <QItemSection>Charts</QItemSection>
                  </QItem>

                  <QItem clickable @click="onInspect">
                    <QItemSection avatar>
                      <QIcon color="primary" :name="inspectIcon" />
                    </QItemSection>

                    <QItemSection>Inspect</QItemSection>
                  </QItem>

                  <QItem clickable @click="onEdit">
                    <QItemSection avatar>
                      <QIcon color="amber" :name="editIcon" />
                    </QItemSection>

                    <QItemSection>Edit</QItemSection>
                  </QItem>

                  <QItem clickable @click="onDelete">
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

        <QItem v-if="record.last_note">
          <QItemSection>
            <QItemLabel>
              <QIcon size="xs" class="q-pb-xs" :name="noteIcon" />
              Previous Note
            </QItemLabel>
            <QItemLabel caption>
              <SharedUserText :text="record.last_note" />
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
              @click="onStart"
            />
          </QItemSection>
        </QItem>
      </QCard>
    </QItemSection>
  </QItem>
</template>
