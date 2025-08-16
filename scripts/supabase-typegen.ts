import { execSync } from 'child_process'
import path from 'path'
import { fileURLToPath } from 'url'

/**
 * Generates the Supabase types from the local Supabase instance.
 *
 * @usage
 * npx tsx scripts/supabase-typegen.ts
 */
function supabaseTypegen() {
  try {
    execSync(`npx supabase gen types typescript --local > shared/types/supabase.ts`)
  } catch (error) {
    console.error('Error generating Supabase types:', error)
    process.exit(1)
  }

  console.log(`Script "${path.basename(fileURLToPath(import.meta.url))}" completed successfully!`)
}

supabaseTypegen()
