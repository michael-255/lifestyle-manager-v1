<script setup lang="ts">
import * as Plot from '@observablehq/plot'
import { onBeforeUnmount, onMounted, ref } from 'vue'

const props = defineProps<{
  id: IdType
}>()

const logger = useLogger()
const supabase = useSupabaseClient<Database>()

const chartContainer = ref<HTMLElement | null>(null)
let chart: HTMLElement | SVGSVGElement | null = null

onMounted(async () => {
  try {
    const { data: resultsData, error: resultsError } = await supabase
      .from('workout_results')
      .select('created_at, finished_at, exercise_results, note')
      .eq('workout_id', props.id)
      .order('created_at', { ascending: false })
    if (resultsError) throw resultsError

    const chartData = (resultsData || [])
      .filter((r) => r.created_at && r.finished_at)
      .map((r) => ({
        finished_at: new Date(r.finished_at!),
        duration: (new Date(r.finished_at!).getTime() - new Date(r.created_at).getTime()) / 60000, // minutes
      }))

    chart = Plot.plot({
      x: { label: 'Finished At', type: 'utc' },
      y: { label: 'Duration (min)' },
      marks: [
        Plot.dot(chartData, {
          x: 'finished_at',
          y: 'duration',
          fill: 'steelblue',
        }),
        Plot.line(chartData, { x: 'finished_at', y: 'duration', stroke: 'steelblue' }),
      ],
    })

    if (chartContainer.value && chart) {
      chartContainer.value.appendChild(chart)
    }
  } catch (error) {
    logger.error('Error charting workout data', { error })
  }
})

onBeforeUnmount(() => {
  // clean up old chart when component is destroyed
  if (chart) chart.remove()
})
</script>

<template>
  <DialogCharts :id label="Workout" :is-loading="false"><div ref="chartContainer" /></DialogCharts>
</template>
