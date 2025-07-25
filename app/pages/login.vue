<script setup lang="ts">
import { useSupabaseClient } from '#imports'
import { QBtn, QInput } from 'quasar'
import { ref } from 'vue'
import { appTitle } from '~~/shared/constants'

useMeta({ title: `${appTitle} | Login` })

const $q = useQuasar()
const router = useRouter()
const logger = useLogger()
const supabase = useSupabaseClient()
const settingsStore = useSettingsStore()

const email = ref(settingsStore.userEmail || '')
const password = ref('')

async function login() {
  try {
    $q.loading.show()

    const { error: loginError } = await supabase.auth.signInWithPassword({
      email: email.value,
      password: password.value,
    })

    console.log('NUXT_PUBLIC_SUPABASE_URL:', process.env.NUXT_PUBLIC_SUPABASE_URL)
    console.log('NUXT_PUBLIC_SUPABASE_KEY:', process.env.NUXT_PUBLIC_SUPABASE_KEY)

    if (loginError) {
      logger.error(loginError.message, loginError)
    } else {
      await router.replace('/')
    }
  } catch (error) {
    logger.error('Unexpected login error', error as Error)
  } finally {
    $q.loading.hide()
  }
}
</script>

<template>
  <div class="flex flex-center content-container">
    <QForm class="q-pa-lg content-extra" @submit.prevent="login">
      <h4 class="text-center">{{ appTitle }}</h4>

      <div class="text-h5 q-mb-lg">Login</div>

      <QInput
        v-model="email"
        label="Email"
        type="email"
        outlined
        autofocus
        class="q-mb-md"
        :rules="[
          (val: string) => emailSchema.safeParse(val).success || 'Must use a valid email address',
        ]"
        :disable="$q.loading.isActive"
      />

      <QInput
        v-model="password"
        label="Password"
        type="password"
        outlined
        class="q-mb-md"
        :rules="[(val: string) => !!val || 'Password is required']"
        :disable="$q.loading.isActive"
      />

      <QBtn
        label="Login"
        color="primary"
        type="submit"
        class="q-mt-md full-width"
        :disable="$q.loading.isActive"
      />
    </QForm>
  </div>
</template>

<style scoped>
.content-container {
  min-height: 80vh;
}

.content-extra {
  max-width: 25rem;
  width: 100%;
}
</style>
