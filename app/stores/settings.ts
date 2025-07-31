import { settingKeys } from '#shared/constants'
import { defineStore } from 'pinia'

/**
 * The default values for each setting are defined in `local-database.ts`
 */
export const useSettingsStore = defineStore('settings', {
  state: () => ({
    settings: [] as SettingType[],
  }),

  /**
   * Destructing the getters from the store will break reactivity.
   * Use settingsStore.{getter} instead.
   */
  getters: {
    // Supabase
    userEmail: (state) => {
      return state.settings.find((s: SettingType) => s.key === settingKeys.enum['User Email'])
        ?.value as string
    },

    // App
    consoleLogs: (state) => {
      return state.settings.find((s: SettingType) => s.key === settingKeys.enum['Console Logs'])
        ?.value as boolean
    },

    infoPopus: (state) => {
      return state.settings.find((s: SettingType) => s.key === settingKeys.enum['Info Popups'])
        ?.value as boolean
    },

    logRetentionDuration: (state) => {
      return state.settings.find(
        (s: SettingType) => s.key === settingKeys.enum['Log Rentention Duration'],
      )?.value as string
    },
  },
})
