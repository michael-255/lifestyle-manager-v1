<script setup lang="ts">
import { exitIcon } from '#shared/constants'
import { useQuasar } from 'quasar'

const $q = useQuasar()
const isDesktop = computed(() => $q.screen.gt.xs)
</script>

<template>
  <QLayout view="hHh lpr lfr">
    <QHeader bordered>
      <QTabs class="text-caption" active-color="yellow" outside-arrows mobile-arrows>
        <QRouteTab no-caps :icon="exitIcon" exact to="/">
          <template v-if="isDesktop">Exit</template>
        </QRouteTab>
      </QTabs>
    </QHeader>

    <LayoutContainer />
  </QLayout>
</template>
