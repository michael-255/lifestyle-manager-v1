import { defineStore } from 'pinia'

/**
 * Storing the current active workout basic information.
 */
export const useWorkoutStore = defineStore('workout', {
  state: () => ({
    name: '' as string,
    workoutResultCreatedAt: '' as string,
  }),
})
