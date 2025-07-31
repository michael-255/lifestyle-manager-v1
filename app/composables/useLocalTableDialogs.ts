import {
  DialogInspect,
  DialogInspectItemDate,
  DialogInspectItemObject,
  DialogInspectItemText,
} from '#components'

export default function useLocalTableDialogs() {
  const $q = useQuasar()

  function openInspectLog(log: LogType) {
    $q.dialog({
      component: DialogInspect,
      componentProps: {
        label: 'Log',
        subComponents: [
          { component: DialogInspectItemText, props: { label: 'Id', value: log.id } },
          {
            component: DialogInspectItemDate,
            props: { label: 'Created Date', value: log.created_at },
          },
          {
            component: DialogInspectItemText,
            props: { label: 'Log Level', value: log.log_level },
          },
          { component: DialogInspectItemText, props: { label: 'Label', value: log.label } },
          {
            component: DialogInspectItemObject,
            props: { label: 'Details', value: log.details },
          },
        ],
      },
    })
  }

  function openInspectSetting(setting: SettingType) {
    $q.dialog({
      component: DialogInspect,
      componentProps: {
        label: 'Setting',
        subComponents: [
          {
            component: DialogInspectItemText,
            props: { label: 'Id', value: setting.id },
          },
          {
            component: DialogInspectItemText,
            props: { label: 'Value', value: setting.value },
          },
        ],
      },
    })
  }

  return { openInspectLog, openInspectSetting }
}
