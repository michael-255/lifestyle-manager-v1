<script setup lang="ts">
import type { WorkoutExerciseOption } from '#shared/types/fitness-schemas'
import { onMounted, ref } from 'vue'

const logger = useLogger()
const supabase = useSupabaseClient<Database>()
const localRecordStore = useLocalRecordStore()

const options: Ref<WorkoutExerciseOption[]> = ref([])

onMounted(async () => {
  try {
    const { data, error } = await supabase.from('workout_exercise_options').select('*')
    if (error) throw error

    options.value = data ?? []
  } catch (error) {
    logger.error('Failed to fetch workout exercise options:', error as Error)
  }
})
</script>

<template>
  <DialogFormSharedItem label="Exercises">
    <QItemLabel>
      <QSelect
        v-model="localRecordStore.record.exercises"
        :options="options"
        multiple
        counter
        emit-value
        map-options
        options-dense
        dense
        outlined
        color="primary"
      >
        <template #option="scope">
          <QItem v-bind="scope.itemProps">
            <QItemSection>
              <template
                v-if="
                  localRecordStore.record.exercises &&
                  localRecordStore.record.exercises.includes(scope.opt.value)
                "
              >
                {{ localRecordStore.record.exercises.indexOf(scope.opt.value) + 1 + '. ' }}
              </template>
              {{ scope.opt.label }}
            </QItemSection>
          </QItem>
        </template>
      </QSelect>
    </QItemLabel>
  </DialogFormSharedItem>
</template>
