<script setup lang="ts">
import { onMounted, ref } from 'vue'
import type { WorkoutExerciseOption } from '~~/shared/types/fitness-schemas'

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
  <DialogFormItem label="Exercises">
    <QItemLabel>
      <QSelect
        v-model="localRecordStore.record.exercises"
        :options="options"
        lazy-rules
        multiple
        counter
        emit-value
        map-options
        options-dense
        dense
        outlined
        color="primary"
      />
    </QItemLabel>
  </DialogFormItem>
</template>
