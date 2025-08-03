import { defineStore } from 'pinia'

/**
 * Storing the currently selected record locally for actions like create and edit.
 */
export const useLocalRecordStore = defineStore('local-record', {
  state: () => ({
    record: {} as Record<string, any>,
  }),

  getters: {
    /**
     * Returns only the editable fields of the Workout.
     */
    getWorkout: (state) => {
      return {
        created_at: state.record?.created_at,
        name: state.record?.name,
        description: state.record?.description,
        schedule: state.record?.schedule,
      }
    },

    getWorkoutExercises: (state) => {
      return state.record?.exercises || []
    },
  },
})
