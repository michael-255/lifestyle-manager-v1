import {
  symRoundedAdd2,
  symRoundedAddCircle,
  symRoundedAssignment,
  symRoundedBugReport,
  symRoundedCalendarMonth,
  symRoundedCalendarToday,
  symRoundedCancel,
  symRoundedCheckCircle,
  symRoundedClose,
  symRoundedDatabase,
  symRoundedDelete,
  symRoundedDeleteForever,
  symRoundedDownload,
  symRoundedEdit,
  symRoundedError,
  symRoundedEventAvailable,
  symRoundedExitToApp,
  symRoundedFeatureSearch,
  symRoundedFitnessCenter,
  symRoundedGridView,
  symRoundedInfo,
  symRoundedLists,
  symRoundedLock,
  symRoundedLockOpenRight,
  symRoundedLogout,
  symRoundedManageSearch,
  symRoundedMonitoring,
  symRoundedMoreVert,
  symRoundedNotifications,
  symRoundedPerson,
  symRoundedPlayArrow,
  symRoundedPublish,
  symRoundedRefresh,
  symRoundedSave,
  symRoundedSchedule,
  symRoundedSearch,
  symRoundedSettings,
  symRoundedSmartToy,
  symRoundedStat2,
  symRoundedStickyNote2,
  symRoundedStorage,
  symRoundedTune,
  symRoundedViewWeek,
  symRoundedWarning,
} from '@quasar/extras/material-symbols-rounded'
import { z } from 'zod'

//
// General
//

export const appTitle = 'Lifestyle Manager'
export const appDescription = `${appTitle} is a project for managing your daily activities, health, and wellness.`

// Date format for displaying readable dates in the UI
export const localDisplayDateFormat = 'ddd, YYYY MMM Do, h:mm A' // Sun, 2024 Sep 1st, 12:17 PM
// Date format for displaying in date-time pickers
export const localPickerDateFormat = 'YYYY-MM-DDTHH:mm' // 2024-09-01T12:17:00.000
// Date format for saving to the database in UTC
export const utcDateFormat = 'YYYY-MM-DDTHH:mm:ss.SSS[Z]' // 2024-09-01T12:17:00.000Z

export const settingKeys = z.enum([
  'User Email',
  'Console Logs',
  'Info Popups',
  'Log Rentention Duration',
])

export const logLevels = z.enum(['DEBUG', 'INFO', 'WARN', 'ERROR'])

export const durationNames = z.enum([
  'Now',
  'One Second',
  'One Minute',
  'One Hour',
  'One Day',
  'One Week',
  'One Month',
  'Three Months',
  'Six Months',
  'One Year',
  'Two Years',
  'Three Years',
  'All Time',
  'Forever',
])

/**
 * Icons
 * Use `string` as the expected type for Icons.
 * @see https://fonts.google.com/icons
 * @see https://quasar.dev/vue-components/icon#import-guide
 */

// Log Levels (Severity)
export const debugIcon = symRoundedBugReport
export const infoIcon = symRoundedInfo
export const warnIcon = symRoundedWarning
export const errorIcon = symRoundedError

// Pages
export const examplesIcon = symRoundedSmartToy
export const dashboardIcon = symRoundedGridView
export const logsIcon = symRoundedFeatureSearch
export const notificationsIcon = symRoundedNotifications
export const settingsIcon = symRoundedSettings
export const fitnessIcon = symRoundedFitnessCenter
export const workoutIcon = symRoundedAssignment
export const chartsIcon = symRoundedMonitoring

// Actions
export const saveIcon = symRoundedSave
export const addIcon = symRoundedAdd2
export const createIcon = symRoundedAddCircle
export const editIcon = symRoundedEdit
export const closeIcon = symRoundedClose
export const cancelIcon = symRoundedCancel
export const goToTopIcon = symRoundedStat2
export const lockIcon = symRoundedLock
export const unlockIcon = symRoundedLockOpenRight
export const importFileIcon = symRoundedPublish
export const exportFileIcon = symRoundedDownload
export const refreshIcon = symRoundedRefresh
export const deleteIcon = symRoundedDelete
export const deleteXIcon = symRoundedDeleteForever
export const exitIcon = symRoundedExitToApp
export const logoutIcon = symRoundedLogout
export const searchIcon = symRoundedSearch
export const cardMenuIcon = symRoundedLists
export const startIcon = symRoundedPlayArrow
export const completedIcon = symRoundedCheckCircle
export const noteIcon = symRoundedStickyNote2

// Design Elements
export const userIcon = symRoundedPerson
export const optionsIcon = symRoundedTune
export const storageIcon = symRoundedStorage
export const columnsIcon = symRoundedViewWeek
export const inspectIcon = symRoundedManageSearch
export const databaseIcon = symRoundedDatabase
export const calendarIcon = symRoundedCalendarToday
export const calendarCheckIcon = symRoundedEventAvailable
export const calendarScheduleIcon = symRoundedCalendarMonth
export const scheduleTimeIcon = symRoundedSchedule
export const verticalDotMenuIcon = symRoundedMoreVert
