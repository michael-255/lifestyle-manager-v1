import { z } from 'zod'
import { logLevels, settingKeys } from '../constants'
import { timestampzSchema } from './common-schemas'

//
// Settings
//

// settingKeys enum can be used as a zod schema
export const settingValueSchema = z.union([z.boolean(), z.string(), z.number()])
export const settingSchema = z.object({
  key: settingKeys,
  value: settingValueSchema,
})

export type SettingKeyType = z.infer<typeof settingKeys>
export type SettingValueType = z.infer<typeof settingValueSchema>
export type SettingType = z.infer<typeof settingSchema>

//
// Logs
//

export const LogAutoIdSchema = z.number().optional() // Auto-incremented by Dexie
export const logLabelSchema = z.string().trim()
export const logDetailsSchema = z.record(z.any()).or(z.instanceof(Error)).optional()
export const logSchema = z.object({
  autoId: LogAutoIdSchema,
  created_at: timestampzSchema,
  log_level: logLevels,
  label: logLabelSchema,
  details: logDetailsSchema,
})

export type LogAutoIdType = z.infer<typeof LogAutoIdSchema>
export type LogLevelType = z.infer<typeof logLevels>
export type LogLabelType = z.infer<typeof logLabelSchema>
export type LogDetailsType = z.infer<typeof logDetailsSchema>
export type LogType = z.infer<typeof logSchema>
