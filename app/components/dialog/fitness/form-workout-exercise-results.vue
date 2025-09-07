<script setup lang="ts">
import { cancelIcon } from '~~/shared/constants'

const recordStore = useRecordStore()
</script>

<template>
  <div v-for="(exercise, exIdx) in recordStore.record.exercises" :key="exIdx">
    <QSeparator inset class="q-my-md" />

    <QItem>
      <QItemSection>
        <QItemLabel class="q-mb-sm text-body1">{{ exercise.name }}</QItemLabel>

        <QCheckbox
          v-for="(item, itemIdx) in exercise.checklist"
          :key="itemIdx"
          v-model="recordStore.record.exercise_results[exIdx].checked[itemIdx]"
          :label="item"
          :disable="!recordStore.record.exercise_results[exIdx]"
        />
      </QItemSection>
    </QItem>

    <DialogSharedBaseItemForm label="Exercise Notes">
      <QItemLabel>
        <QInput
          v-model="recordStore.record.exercise_results[exIdx].note"
          :rules="[
            (val: string) =>
              !val ||
              val.length <= limitRuleLookup.maxTextArea ||
              `Notes cannot exceed ${limitRuleLookup.maxTextArea} characters`,
          ]"
          :maxlength="limitRuleLookup.maxTextArea"
          type="textarea"
          lazy-rules
          autogrow
          counter
          dense
          outlined
          color="primary"
          @blur="
            recordStore.record.exercise_results[exIdx].note =
              recordStore.record.exercise_results[exIdx].note?.trim()
          "
        >
          <template #append>
            <QIcon
              v-if="
                recordStore.record.exercise_results[exIdx].note &&
                recordStore.record.exercise_results[exIdx].note !== ''
              "
              class="cursor-pointer"
              :name="cancelIcon"
              @click="recordStore.record.exercise_results[exIdx].note = ''"
            />
          </template>
        </QInput>
      </QItemLabel>
    </DialogSharedBaseItemForm>
  </div>
</template>
