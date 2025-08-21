import { defineStore } from 'pinia'

/**
 * Storing the currently selected record locally for actions like create and edit.
 */
export const useRecordStore = defineStore('record', {
  state: () => ({
    record: {} as Record<string, any>,
    action: null as 'CREATE' | 'EDIT' | null | undefined,
  }),
})
