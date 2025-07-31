import { closeIcon } from './shared/constants'

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  future: {
    compatibilityVersion: 4,
  },
  compatibilityDate: '2025-05-15',
  devtools: { enabled: true },
  ssr: false,
  nitro: { preset: 'static' },
  modules: [
    '@nuxt/eslint',
    '@nuxt/test-utils',
    '@nuxtjs/supabase',
    '@pinia/nuxt',
    'nuxt-quasar-ui',
  ],
  css: ['@/assets/css/main.css'],
  app: { baseURL: '/lifestyle-manager-v1/' },
  supabase: {
    redirect: true, // To login page
  },
  quasar: {
    config: {
      dark: true,
      brand: {
        primary: '#1976d2', // blue-8
        secondary: '#607d8b', // blue-grey
        accent: '#e91e63', // pink
        info: '#673ab7', // deep-purple
        warning: '#ff6f00', // amber-10
        negative: '#b71c1c', // red-10
        positive: '#4caf50', // green
        dark: '#1d1d1d',
        'dark-page': '#121212',
      },
      notify: {
        textColor: 'white',
        position: 'bottom',
        multiLine: false,
        iconSize: '2rem',
        progress: true,
        timeout: 5000,
        actions: [
          {
            icon: closeIcon,
            round: true,
            color: 'white',
          },
        ],
      },
    },
    plugins: ['Dialog', 'Meta', 'Notify', 'Loading'],
  },
})
