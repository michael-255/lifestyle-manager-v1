<script setup lang="ts">
const props = defineProps<{
  id: IdType
}>()

const $q = useQuasar()
const logger = useLogger()
// const supabase = useSupabaseClient<Database>()
const localRecordStore = useLocalRecordStore()

const label = 'Workout Result'

const isLoading = ref(true)

onMounted(async () => {
  try {
    $q.loading.show()

    localRecordStore.record = {}
  } catch (error) {
    logger.error('Error opening workout result edit dialog', error as Error)
  } finally {
    isLoading.value = false
    $q.loading.hide()
  }
})

async function onSubmit() {
  logger.info('Workout result updated', { id: props.id })
}
</script>

<template>
  <DialogEdit :label="label" :on-submit-handler="onSubmit" :is-loading> Pending... </DialogEdit>
</template>
