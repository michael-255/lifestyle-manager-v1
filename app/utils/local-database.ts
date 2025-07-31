import { appTitle, durationNames, settingKeys } from '#shared/constants'
import {
  timestampzSchema,
  type DurationNameType,
  type TimestampzType,
} from '#shared/types/common-schemas'
import type {
  LogAutoIdType,
  LogType,
  SettingKeyType,
  SettingType,
  SettingValueType,
} from '#shared/types/local-schemas'
import Dexie, { liveQuery, type Observable, type Table } from 'dexie'
import { Log } from '~/models/Log'
import { Setting } from '~/models/Setting'
import { durationLookup } from '~~/shared/utils/utils'

/**
 * The database for the application defining the tables that are available and the models that are
 * mapped to those tables. An instance of this class is created and exported at the end of the file.
 */
export class LocalDatabase extends Dexie {
  // Required for easier TypeScript usage
  logs!: Table<Log>
  settings!: Table<Setting>

  constructor(name: string) {
    super(name)

    this.version(1).stores({
      logs: '++autoId, created_at',
      settings: '&key',
    })

    this.logs.mapToClass(Log)
    this.settings.mapToClass(Setting)
  }

  /**
   * Initializes the settings in the local database. If the settings already exist, they are not
   * overwritten. If the settings do not exist, they are created with default values.
   * @note This MUST be called in `App.vue` on startup
   */
  async initializeSettings(): Promise<void> {
    const defaultSettings: Record<SettingKeyType, SettingValueType> = {
      'User Email': '',
      'Console Logs': false,
      'Info Popups': false,
      'Log Rentention Duration': durationNames.enum['Six Months'],
    }

    // Get all settings or create them with default values
    const settings = await Promise.all(
      settingKeys.options.map(async (key: SettingKeyType) => {
        const setting = await this.settings.get(key)
        if (setting) {
          return setting
        } else {
          return new Setting(key, defaultSettings[key])
        }
      }),
    )

    await Promise.all(settings.map((setting) => this.settings.put(setting)))
  }

  /**
   * Deletes all logs that are older than the retention time set in the settings. If the retention
   * time is set to 'Forever', no logs will be deleted. This should be called on app startup.
   * @returns The number of logs deleted
   */
  async deleteExpiredLogs() {
    const setting = await this.settings.get(settingKeys.enum['Log Rentention Duration'])
    const durationName = setting?.value as DurationNameType
    const durationValue = durationLookup[durationName]
    const durationForever = durationLookup.Forever

    if (!durationName || durationValue >= durationForever) {
      return 0 // No logs purged
    }

    const allLogs = await this.logs.toArray()
    const now = Date.now()

    // Find Logs that are older than the retention time and map them to their keys
    const removableLogs = allLogs
      .filter((log: LogType) => {
        // Skip logs with invalid dates instead of marking them for deletion
        if (!timestampzSchema.safeParse(log.created_at).success) {
          return false
        }
        const logTimestamp = new Date(log.created_at as TimestampzType).getTime()
        const logAge = now - logTimestamp
        return logAge > durationValue
      })
      .map((log: LogType) => log.autoId) // Map remaining Log ids for removal

    await this.logs.bulkDelete(removableLogs as LogAutoIdType[])
    return removableLogs.length // Number of logs deleted
  }

  /**
   * Returns an observable of the logs in the database. The logs are ordered by created_at in
   * descending order. This is a live query, so it will update automatically when the database
   * changes.
   */
  liveLogs(): Observable<LogType[]> {
    return liveQuery(() => this.logs.orderBy('created_at').reverse().toArray())
  }

  /**
   * Returns an observable of the settings in the database. The settings are ordered by created_at
   * in descending order. This is a live query, so it will update automatically when the database
   * changes.
   */
  liveSettings(): Observable<SettingType[]> {
    return liveQuery(() => this.settings.toArray())
  }
}

/**
 * Pre-instantiated database instance that can be used throughout the application.
 */
export const localDatabase = new LocalDatabase(appTitle)
