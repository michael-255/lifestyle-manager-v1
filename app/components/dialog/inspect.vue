<script setup lang="ts">
import { closeIcon, inspectIcon } from '#shared/constants'
import { useDialogPluginComponent } from 'quasar'

defineProps<{
  label: string
  subComponents: Array<{ component: string; props: Record<string, any> }>
}>()

defineEmits([...useDialogPluginComponent.emits])
const { dialogRef, onDialogHide, onDialogCancel } = useDialogPluginComponent()
</script>

<template>
  <QDialog
    ref="dialogRef"
    transition-show="slide-up"
    transition-hide="slide-down"
    maximized
    @hide="onDialogHide()"
  >
    <QToolbar class="bg-primary text-white fullscreen-toolbar-height">
      <QIcon :name="inspectIcon" size="sm" class="q-mx-sm" />
      <QToolbarTitle>Inspect {{ label }}</QToolbarTitle>
      <QBtn flat round :icon="closeIcon" @click="onDialogCancel()" />
    </QToolbar>

    <QCard class="q-dialog-plugin">
      <QCardSection>
        <div class="row justify-center">
          <div class="page-width-limit">
            <QList padding>
              <component
                :is="subComponent.component"
                v-for="(subComponent, index) in subComponents"
                :key="index"
                v-bind="subComponent.props"
              />
            </QList>
            <div class="q-mt-xl" />
          </div>
        </div>
      </QCardSection>
    </QCard>
  </QDialog>
</template>
