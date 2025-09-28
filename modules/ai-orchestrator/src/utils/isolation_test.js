// src/utils/isolation_test.js
// This script writes a unique record to the database to identify which project is being used.
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config();

const { SUPABASE_URL, SUPABASE_SERVICE_KEY, SCANNER_PROJECT_ID } = process.env;
const PING_MESSAGE = `ISOLATION_TEST_PING_${new Date().toISOString()}`;

async function runIsolationTest() {
  console.log(" Running database isolation test...");
  if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
    console.error("❌ FAILED: SUPABASE_URL or SUPABASE_SERVICE_KEY is missing from .env");
    return;
  }
  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const { error } = await supabase.from('project_logs').insert({
      project_id: SCANNER_PROJECT_ID || '00000000-0000-0000-0000-000000000000',
      log_level: 'info',
      message: PING_MESSAGE
    });
    if (error) throw error;
    console.log(`✅ SUCCESS: Ping sent with message: "${PING_MESSAGE}"`);
  } catch (error) {
    console.error("❌ FAILED: Could not write to the database. Error:", error.message);
  }
}
runIsolationTest();