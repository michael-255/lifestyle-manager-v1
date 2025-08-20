<script setup lang="ts">
const logger = useLogger()
// const supabase = useSupabaseClient<Database>()
const localRecordStore = useLocalRecordStore()

const label = 'Exercise Result'

// TODO
localRecordStore.record = {
  created_at: new Date().toISOString(),
}

async function onSubmit() {
  logger.info('Exercise result created')
}
</script>

<template>
  <DialogCreate :label="label" :on-submit-handler="onSubmit" :is-loading="false" />
</template>
