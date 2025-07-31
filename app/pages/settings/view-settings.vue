<script setup lang="ts">
import { appTitle, closeIcon } from '#shared/constants'
import type { SettingType } from '#shared/types/local-schemas'
import { recordCount, tableColumn, visibleColumnsFromTableColumns } from '#shared/utils/utils'
import { useMeta } from 'quasar'
import { onUnmounted, ref, type Ref } from 'vue'
import { localDatabase } from '~/utils/local-database'

useMeta({ title: `${appTitle} | View Settings` })

const logger = useLogger()
const { goBack } = useRouting()
const { openInspectSetting } = useLocalTableDialogs()

const labelSingular = 'Setting'
const labelPlural = 'Settings'
const searchFilter: Ref<string> = ref('')
const tableColumns = [tableColumn('key', 'Key'), tableColumn('value', 'Value', 'SETTING')]
const visibleColumns: Ref<string[]> = ref(visibleColumnsFromTableColumns(tableColumns))

const liveData: Ref<SettingType[]> = ref([])
const isLiveQueryFinished = ref(false)

const subscription = localDatabase.liveSettings().subscribe({
  next: (data) => {
    liveData.value = data
    isLiveQueryFinished.value = true
  },
  error: (error) => {
    logger.error(`Error loading live ${labelPlural} data`, error as Error)
    isLiveQueryFinished.value = true
  },
})

onUnmounted(() => {
  subscription.unsubscribe()
})
</script>

<template>
  <QTable
    fullscreen
    :rows="liveData"
    :columns="tableColumns"
    :visible-columns="visibleColumns"
    :rows-per-page-options="[0]"
    :filter="searchFilter"
    virtual-scroll
    row-key="key"
  >
    <template #header="props">
      <QTr :props="props">
        <QTh v-for="col in props.cols" :key="col.name" :props="props">
          {{ col.label }}
        </QTh>
      </QTr>
    </template>

    <template #body="props">
      <QTr :props="props" class="cursor-pointer" @click="openInspectSetting(props.row)">
        <QTd v-for="col in props.cols" :key="col.name" :props="props">
          {{ col.value }}
        </QTd>
      </QTr>
    </template>

    <template #top>
      <div class="row justify-start full-width q-mb-md">
        <div class="col-10 text-h6 text-bold ellipsis">
          {{ labelPlural }}
        </div>

        <QBtn
          round
          flat
          class="absolute-top-right q-mr-sm q-mt-sm"
          :icon="closeIcon"
          @click="goBack()"
        />
      </div>

      <div class="row justify-start full-width">
        <QInput
          v-model="searchFilter"
          :disable="!liveData.length"
          outlined
          dense
          clearable
          debounce="300"
          placeholder="Search"
          class="full-width"
        />
      </div>
    </template>

    <template #bottom>
      {{ recordCount(liveData, labelSingular) }}
    </template>
  </QTable>
</template>
