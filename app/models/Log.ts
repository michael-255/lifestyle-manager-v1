import type { TimestampzType } from '#shared/types/common-schemas'
import type { LogDetailsType, LogLabelType, LogLevelType } from '#shared/types/local-schemas'

/**
 * Log stored in the local browser databse for the app.
 */
export class Log {
  autoId?: number // Auto-incremented by Dexie
  created_at: TimestampzType
  log_level: LogLevelType
  label: LogLabelType
  details?: LogDetailsType

  constructor(logLevel: LogLevelType, label: LogLabelType, details?: LogDetailsType) {
    this.created_at = new Date().toISOString()
    this.log_level = logLevel
    this.label = label

    if (details instanceof Error) {
      this.details = {
        name: details.name,
        message: details.message,
        stack: details.stack,
      }
    } else {
      this.details = details
    }
  }
}
