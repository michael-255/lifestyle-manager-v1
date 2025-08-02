<script setup lang="ts">
import { DialogConfirm } from '#components'
import { closeIcon, createIcon, saveIcon } from '#shared/constants'
import useLogger from '@/composables/useLogger'
import { useDialogPluginComponent, useQuasar } from 'quasar'
import { ref } from 'vue'

const props = defineProps<{
  label: string
  subComponents: Array<{ component: string; props: Record<string, any> }>
  onSubmitHandler: () => Promise<Record<string, any> | null>
}>()

defineEmits([...useDialogPluginComponent.emits])
const { dialogRef, onDialogHide, onDialogCancel, onDialogOK } = useDialogPluginComponent()

const $q = useQuasar()
const logger = useLogger()

const isFormValid = ref(true)

async function onSubmit() {
  $q.dialog({
    component: DialogConfirm,
    componentProps: {
      title: `Create ${props.label}`,
      message: `Are you sure you want to create this ${props.label}?`,
      color: 'positive',
      icon: saveIcon,
      requiresUnlock: false,
    },
  }).onOk(async () => {
    try {
      $q.loading.show()

      const record = await props.onSubmitHandler()

      logger.info(`${props.label} created`, record)
    } catch (error) {
      logger.error(`Error creating ${props.label}`, error as Error)
    } finally {
      $q.loading.hide()
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
    @hide="onDialogHide"
  >
    <QToolbar class="bg-primary text-white fullscreen-toolbar-height q-pr-xs">
      <QIcon :name="createIcon" size="sm" />
      <QToolbarTitle>Create {{ label }}</QToolbarTitle>
      <QBtn flat round :icon="closeIcon" @click="onDialogCancel" />
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
              <QList padding>
                <component
                  :is="subComponent.component"
                  v-for="(subComponent, index) in subComponents"
                  :key="index"
                  v-bind="subComponent.props"
                />

                <QItem>
                  <QItemSection>
                    <QItemLabel>
                      <div class="row justify-center">
                        <QBtn
                          :label="`Create ${label}`"
                          :icon="saveIcon"
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
