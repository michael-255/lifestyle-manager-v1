import { defineStore } from 'pinia'

/**
 * Storing the current active workout basic information.
 */
export const useWorkoutStore = defineStore('workout', {
  state: () => ({
    workout: {} as Record<string, any>,
    workoutResult: {} as Record<string, any>,
  }),
})
