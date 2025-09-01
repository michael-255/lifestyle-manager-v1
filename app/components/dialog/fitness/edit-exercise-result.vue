<script setup lang="ts">
const props = defineProps<{
  id: IdType
}>()

const $q = useQuasar()
const logger = useLogger()
// const supabase = useSupabaseClient<Database>()
const recordStore = useRecordStore()

const isLoading = ref(true)

onMounted(async () => {
  try {
    $q.loading.show()

    recordStore.record = {}
  } catch (error) {
    logger.error('Error opening exercise result edit dialog', error as Error)
  } finally {
    isLoading.value = false
    $q.loading.hide()
  }
})

async function onSubmit() {
  // TODO: implement
  logger.info('Exercise result updated', { id: props.id })
}
</script>

<template>
  <DialogEdit label="Exercise Result" :on-submit-handler="onSubmit" :is-loading>
    Pending...
  </DialogEdit>
</template>
