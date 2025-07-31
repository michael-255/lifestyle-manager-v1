import type { SettingKeyType, SettingValueType } from '#shared/types/local-schemas'

/**
 * Setting model is used for app wide settings. They are initialized and live
 * queried during startup in `App.vue` and inserted into a store for easy access.
 */
export class Setting {
  key: SettingKeyType
  value: SettingValueType

  constructor(key: SettingKeyType, value: SettingValueType) {
    this.key = key
    this.value = value
  }
}
