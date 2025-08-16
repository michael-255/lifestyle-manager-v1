<script setup lang="ts">
import { useRouting } from '#imports'
import {
  appTitle,
  chartsIcon,
  closeIcon,
  columnsIcon,
  deleteIcon,
  editIcon,
  inspectIcon,
  searchIcon,
} from '#shared/constants'
import {
  columnOptionsFromTableColumns,
  hiddenTableColumn,
  recordCount,
  tableColumn,
  visibleColumnsFromTableColumns,
} from '#shared/utils/utils'
import { useMeta, type QTableColumn } from 'quasar'
import { ref, type Ref } from 'vue'

useMeta({ title: `${appTitle} | Exercise Data` })

const $q = useQuasar()
const logger = useLogger()
const supabase = useSupabaseClient<Database>()
const { openChartExercise, openInspectExercise, openEditExercise, openDeleteExercise } =
  useFitnessDialogs()
const { goBack } = useRouting()

const labelSingular = 'Exercise'
const labelPlural = 'Exercises'
const searchFilter: Ref<string> = ref('')
const tableColumns = [
  hiddenTableColumn('id'),
  tableColumn('id', 'Id', 'UUID'),
  tableColumn('name', 'Name', 'TEXT'),
  tableColumn('description', 'Description', 'TEXT'),
  tableColumn('created_at', 'Created Date', 'ISO-DATE'),
  tableColumn('type', 'Type', 'TEXT'),
  tableColumn('rest_timer', 'Rest Timer', 'TIME'),
  tableColumn('workout_count', 'Workouts Used', 'NUMBER'),
  tableColumn('exercise_result_count', 'Total Results', 'NUMBER'),
  tableColumn('is_locked', 'Locked', 'BOOL'),
]
const columnOptions: Ref<QTableColumn[]> = ref(columnOptionsFromTableColumns(tableColumns))
const visibleColumns: Ref<string[]> = ref(visibleColumnsFromTableColumns(tableColumns))

const records: Ref<any[]> = ref([])

onMounted(async () => {
  try {
    $q.loading.show()

    const { data, error } = await supabase.from('exercises_table').select()
    if (error) throw error

    records.value = data || []
  } catch (error) {
    logger.error(`Error fetching exercises table`, error as Error)
  } finally {
    $q.loading.hide()
  }
})
</script>

<template>
  <QTable
    fullscreen
    :rows="records"
    :columns="tableColumns"
    :visible-columns="visibleColumns"
    :rows-per-page-options="[0]"
    :filter="searchFilter"
    virtual-scroll
    row-key="id"
  >
    <template #header="props">
      <QTr :props="props">
        <QTh
          v-for="col in props.cols"
          v-show="col.name !== 'hidden'"
          :key="col.name"
          :props="props"
        >
          {{ col.label }}
        </QTh>
        <QTh auto-width class="text-left">Actions</QTh>
      </QTr>
    </template>

    <template #body="props">
      <QTr :props="props">
        <QTd v-for="col in props.cols" :key="col.name" :props="props">
          {{ col.value }}
        </QTd>
        <QTd auto-width>
          <QBtn
            :disable="!props.row.exercise_result_count"
            flat
            round
            dense
            class="q-ml-xs"
            :color="!props.row.exercise_result_count ? 'grey' : 'cyan'"
            :icon="chartsIcon"
            @click="openChartExercise(props.row.id)"
          />
          <QBtn
            flat
            round
            dense
            class="q-ml-xs"
            color="primary"
            :icon="inspectIcon"
            @click="openInspectExercise(props.row.id)"
          />
          <QBtn
            :disable="props.row.is_locked"
            flat
            round
            dense
            class="q-ml-xs"
            :icon="editIcon"
            :color="props.row.is_locked ? 'grey' : 'amber'"
            @click="openEditExercise(props.row.id)"
          />
          <QBtn
            :disable="props.row.is_locked"
            flat
            round
            dense
            class="q-ml-xs"
            :color="props.row.is_locked ? 'grey' : 'negative'"
            :icon="deleteIcon"
            @click="openDeleteExercise(props.row.id)"
          />
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
          :disable="!records.length"
          outlined
          dense
          clearable
          debounce="300"
          placeholder="Search"
          class="full-width"
        >
          <template #after>
            <QSelect
              v-model="visibleColumns"
              :options="columnOptions"
              :disable="!records.length"
              multiple
              dense
              options-dense
              emit-value
              map-options
              option-value="name"
              display-value=""
              bg-color="primary"
            >
              <template #append>
                <QIcon color="white" :name="columnsIcon" />
              </template>
            </QSelect>
          </template>

          <template #append>
            <QIcon :name="searchIcon" />
          </template>
        </QInput>
      </div>
    </template>

    <template #bottom>
      {{ recordCount(records, labelSingular) }}
    </template>
  </QTable>
</template>
