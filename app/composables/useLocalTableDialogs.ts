import { DialogCoreInspectLog, DialogCoreInspectSetting } from '#components'

export default function useLocalTableDialogs() {
  const $q = useQuasar()

  function openInspectLog(log: LogType) {
    $q.dialog({
      component: DialogCoreInspectLog,
      componentProps: { log },
    })
  }

  function openInspectSetting(setting: SettingType) {
    $q.dialog({
      component: DialogCoreInspectSetting,
      componentProps: { setting },
    })
  }

  return { openInspectLog, openInspectSetting }
}
