<script setup lang="ts">
import { databaseIcon, exitIcon, planIcon } from '#shared/constants'
import { useQuasar } from 'quasar'

const $q = useQuasar()
const isDesktop = computed(() => $q.screen.gt.xs)
</script>

<template>
  <QLayout view="hHh lpr lfr">
    <QHeader bordered>
      <QTabs class="text-caption" active-color="yellow" outside-arrows mobile-arrows>
        <QRouteTab no-caps :icon="planIcon" exact to="/fitness">
          <template v-if="isDesktop">Today</template>
        </QRouteTab>

        <QRouteTab no-caps :icon="databaseIcon" exact to="/fitness/data">
          <template v-if="isDesktop">Data</template>
        </QRouteTab>

        <QRouteTab no-caps :icon="exitIcon" exact to="/">
          <template v-if="isDesktop">Exit</template>
        </QRouteTab>
      </QTabs>
    </QHeader>

    <LayoutContainer />
  </QLayout>
</template>
