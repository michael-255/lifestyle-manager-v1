import useLogger from '@/composables/useLogger'
import { useRouter } from 'vue-router'

/**
 * Provides routing-related functions.
 */
export default function useRouting() {
  // Do NOT return route or router from any composable due to performance issues
  const router = useRouter()
  const logger = useLogger()

  /**
   * Go back if previous route state is part of the app history, otherwise go to root path.
   */
  function goBack() {
    try {
      if (router?.options?.history?.state?.back) {
        router.back()
      } else {
        router.push('/')
      }
    } catch (error) {
      logger.error('Error accessing previous route', error as Error)
    }
  }

  return { goBack }
}
