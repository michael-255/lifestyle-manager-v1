<script setup lang="ts">
import { DialogConfirm } from '#components'
import { closeIcon, createIcon, saveIcon } from '#shared/constants'
import useLogger from '@/composables/useLogger'
import { useDialogPluginComponent, useQuasar } from 'quasar'
import { ref } from 'vue'

const props = defineProps<{
  label: string
  onSubmitHandler: () => Promise<void>
  isLoading: boolean
}>()

defineEmits([...useDialogPluginComponent.emits])
const { dialogRef, onDialogHide, onDialogCancel, onDialogOK } = useDialogPluginComponent()

const $q = useQuasar()
const logger = useLogger()
const recordStore = useRecordStore()

recordStore.action = 'EDIT'

const isFormValid = ref(true)

function resetStore() {
  recordStore.$reset()
}

function handleDialogHide() {
  resetStore()
  onDialogHide()
}

function handleDialogCancel() {
  resetStore()
  onDialogCancel()
}

async function onSubmit() {
  $q.dialog({
    component: DialogConfirm,
    componentProps: {
      title: `Update ${props.label}`,
      message: `Are you sure you want to update this ${props.label}?`,
      color: 'warning',
      icon: saveIcon,
      requiresUnlock: false,
    },
  }).onOk(async () => {
    try {
      $q.loading.show()
      await props.onSubmitHandler()
    } catch (error) {
      logger.error(`Error updating ${props.label}`, error as Error)
    } finally {
      $q.loading.hide()
      resetStore()
      onDialogOK()
    }
  })
}
</script>

<template>
  <QDialog
    ref="dialogRef"
    transition-show="slide-up"
    transition-hide="slide-down"
    maximized
    @hide="handleDialogHide"
  >
    <QToolbar class="bg-primary text-white fullscreen-toolbar-height q-pr-xs">
      <QIcon :name="createIcon" size="sm" />
      <QToolbarTitle>Edit {{ label }}</QToolbarTitle>
      <QBtn flat round :icon="closeIcon" @click="handleDialogCancel" />
    </QToolbar>

    <QCard class="q-dialog-plugin">
      <QCardSection>
        <div class="row justify-center">
          <div class="page-width-limit">
            <QForm
              class="q-mb-xl"
              @submit.prevent="onSubmit"
              @validation-error="isFormValid = false"
              @validation-success="isFormValid = true"
            >
              <QList v-if="!isLoading" padding>
                <slot />

                <QItem>
                  <QItemSection>
                    <QItemLabel>
                      <div class="row justify-center">
                        <QBtn
                          :label="`Update ${label}`"
                          :icon="saveIcon"
                          :disable="!isFormValid"
                          color="positive"
                          type="submit"
                        />
                      </div>
                    </QItemLabel>
                  </QItemSection>
                </QItem>

                <QItem v-show="!isFormValid">
                  <QItemSection>
                    <div class="row justify-center text-warning">
                      Correct invalid form entries and try again
                    </div>
                  </QItemSection>
                </QItem>
              </QList>
            </QForm>
            <div class="q-mt-xl" />
          </div>
        </div>
      </QCardSection>
    </QCard>
  </QDialog>
</template>
