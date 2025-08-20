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
  <DialogSharedBaseItemForm label="Parent Exercise">
    <QItemLabel>
      <QSelect
        v-model="localRecordStore.record.exercise"
        :options="options"
        emit-value
        map-options
        options-dense
        dense
        outlined
        color="primary"
      />
    </QItemLabel>
  </DialogSharedBaseItemForm>
</template>
