import { createClient } from '@supabase/supabase-js'
import { execSync } from 'child_process'
import fs from 'fs'
import path, { dirname } from 'path'
import { fileURLToPath } from 'url'

const scriptPath = dirname(fileURLToPath(import.meta.url))

const LOCAL_USER = {
  email: 'a@a.com',
  password: '1234',
}

/**
 * Sets up the local ENV file and generates a user for the local Supabase instance.
 *
 * @usage
 * npx tsx scripts/prepare-local-env.ts
 */
async function prepareLocalEnv() {
  let supabaseEnv = {} as any

  // Get local Supabase ENV variables
  try {
    supabaseEnv = JSON.parse(execSync('npx supabase status -o json').toString())
  } catch (error) {
    console.error('Error fetching Supabase ENV variables.', error)
    process.exit(1)
  }

  // Generate local ENV file
  try {
    const newEnv = {
      NUXT_PUBLIC_SUPABASE_URL: supabaseEnv['API_URL'],
      NUXT_PUBLIC_SUPABASE_KEY: supabaseEnv['ANON_KEY'],
      NUXT_PUBLIC_SITE_URL: 'http://localhost:3000/',
      SUPABASE_PROJECT_ID: 'lifestyle-manager-v1',
      SUPABASE_CONNECTION_STRING: supabaseEnv['DB_URL'],
      SUPABASE_SERVICE_ROLE_KEY: supabaseEnv['SERVICE_ROLE_KEY'],
      SUPABASE_JWT_SECRET: supabaseEnv['JWT_SECRET'],
    }

    const projectRoot = path.resolve(scriptPath, '../')
    const envLocalPath = path.join(projectRoot, '.env')
    const envBackupPath = path.join(projectRoot, '.env.backup')

    // Backup existing local ENV file if it exists and no backup ENV exists yet
    if (!fs.existsSync(envBackupPath) && fs.existsSync(envLocalPath)) {
      fs.copyFileSync(envLocalPath, envBackupPath)
    }

    const newEnvString = Object.entries(newEnv)
      .map(([key, value]) => `${key}="${value}"`)
      .join('\n')

    fs.writeFileSync(envLocalPath, newEnvString)
  } catch (error) {
    console.error('Error generating local ENV file:', error)
    process.exit(1)
  }

  try {
    const supabase = createClient<Database>(supabaseEnv['API_URL'], supabaseEnv['SERVICE_ROLE_KEY'])

    const { error } = await supabase.auth.admin.createUser({
      email: LOCAL_USER.email,
      password: LOCAL_USER.password,
      email_confirm: true,
    })
    if (error) throw error
  } catch (error) {
    console.error('Error creating local Supabase user:', error)
    process.exit(1)
  }

  console.log(`Script "${path.basename(fileURLToPath(import.meta.url))}" completed successfully!`)
}

prepareLocalEnv()
