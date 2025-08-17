import { DialogInspect, DialogInspectSharedLog, DialogInspectSharedSetting } from '#components'

export default function useLocalTableDialogs() {
  const $q = useQuasar()

  function openInspectLog(log: LogType) {
    $q.dialog({
      component: DialogInspect,
      componentProps: {
        label: 'Log',
        inspectComponent: { component: DialogInspectSharedLog, props: { log } },
      },
    })
  }

  function openInspectSetting(setting: SettingType) {
    $q.dialog({
      component: DialogInspect,
      componentProps: {
        label: 'Setting',
        inspectComponent: { component: DialogInspectSharedSetting, props: { setting } },
      },
    })
  }

  return { openInspectLog, openInspectSetting }
}
