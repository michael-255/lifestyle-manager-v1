<script setup lang="ts">
// TODO:
/**
 * Make a view to return exercises the following way:
 * @example
 * { value: 'exercise-id', label: 'Exercise Name (id*)', disable: false (if locked) }[]
 */

// const localRecordStore = useLocalRecordStore()

// const options: Ref<{ value: string; label: string; disable: boolean }[]> = ref([])

// onMounted(async () => {
//   try {
//     actionStore.record.exerciseIds = actionStore.record.exerciseIds ?? []
//     options.value = await DB.getExerciseIdOptions()
//   } catch (error) {
//     log.error('Error with exercise ids field', error)
//   }
// })
</script>

<template>
  <DialogFormItem label="Exercises">
    <QItemLabel>
      <!-- <QSelect
        v-model="actionStore.record.exerciseIds"
        :rules="[(val: string[]) => exerciseIdsSchema.safeParse(val).success || 'Required']"
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
      /> -->
    </QItemLabel>
  </DialogFormItem>
</template>
