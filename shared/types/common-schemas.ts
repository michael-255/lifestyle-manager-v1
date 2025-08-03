import { z } from 'zod'
import type { durationNames } from '../constants'

//
// Common
//

// durationNames enum can be used as a zod schema
export const urlSchema = z.string().url()
export const emailSchema = z.string().email()
export const idSchema = z.string().uuid()
export const timestampzSchema = z.string().refine(
  (timestamp) => {
    return !isNaN(Date.parse(timestamp))
  },
  { message: 'Invalid timestamp' },
)
export const textLabelSchema = z.string().min(1).max(limitRuleLookup.maxTextLabel)
export const textAreaSchema = z.string().max(limitRuleLookup.maxTextArea).optional()

//
// Types
//

export type URLType = z.infer<typeof urlSchema>
export type EmailType = z.infer<typeof emailSchema>
export type IdType = z.infer<typeof idSchema>
export type TimestampzType = z.infer<typeof timestampzSchema>
export type TextLabelType = z.infer<typeof textLabelSchema>
export type TextAreaType = z.infer<typeof textAreaSchema>
export type DurationNameType = z.infer<typeof durationNames>

//
// Other
//

export type BackupType = {
  appTitle: string
  createdAt: TimestampzType
  logs: LogType[]
  settings: SettingType[]
}
