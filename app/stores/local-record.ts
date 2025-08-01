import { defineStore } from 'pinia'

/**
 * Storing the currently selected record locally for actions like create and edit.
 */
export const useLocalRecordStore = defineStore('local-record', {
  state: () => ({
    record: {} as Record<string, any>,
    joinedExtras: {} as Record<string, any>,
  }),
})
