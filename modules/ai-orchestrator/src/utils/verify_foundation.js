// src/utils/verify_foundation.js
// This script provides a definitive, final check on the database foundation.
// It verifies that all schema and data are correctly in place before building the orchestrator.

import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const { SUPABASE_URL, SUPABASE_ANON_KEY, SCANNER_PROJECT_ID } = process.env;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY || !SCANNER_PROJECT_ID) {
  console.error("❌ Critical Error: Missing SUPABASE_URL, SUPABASE_ANON_KEY, or SCANNER_PROJECT_ID in .env file.");
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function verifyFoundation() {
  console.log("✅ --- Verifying Rock-Solid Foundation ---");
  let allTestsPassed = true;
  
  try {
    // Test 1: Count active prompts
    console.log(" [1/4] Checking for active prompts...");
    const { data: prompts, error: promptError } = await supabase
      .from('agent_prompts')
      .select('id', { count: 'exact' })
      .eq('project_id', SCANNER_PROJECT_ID)
      .eq('is_active', true);

    if (promptError) throw promptError;
    if (prompts.length >= 4) {
      console.log(`   ✅ Success: Found ${prompts.length} active prompts.`);
    } else {
      console.error(`   ❌ FAILED: Expected at least 4 active prompts, but found ${prompts.length}.`);
      allTestsPassed = false;
    }

    // Test 2: Count chaining rules
    console.log(" [2/4] Checking for chaining rules...");
    const { data: chains, error: chainError } = await supabase
      .from('prompt_chaining_map')
      .select('from_prompt_id', { count: 'exact' });
      
    if (chainError) throw chainError;
    if (chains.length >= 3) {
      console.log(`   ✅ Success: Found ${chains.length} chaining rules.`);
    } else {
      console.error(`   ❌ FAILED: Expected at least 3 chaining rules, but found ${chains.length}.`);
      allTestsPassed = false;
    }

    // Test 3: Find the specific start point
    console.log(" [3/4] Checking for workflow start point...");
    const { data: startPoint, error: startError } = await supabase
      .from('prompt_chaining_map')
      .select('notes, to_prompt:agent_prompts!prompt_chaining_map_to_prompt_id_fkey(prompt_title)')
      .eq('condition->>start_prompt', 'true')
      .single();

    if (startError) throw startError;
    if (startPoint?.to_prompt?.prompt_title) {
        console.log(`   ✅ Success: Workflow starts at "${startPoint.to_prompt.prompt_title}".`);
    } else {
        console.error(`   ❌ FAILED: Could not find a valid workflow start point.`);
        allTestsPassed = false;
    }

    // Test 4: Verify project_logs schema
    console.log(" [4/4] Checking project_logs schema...");
    const { data: log, error: logError } = await supabase
      .from('project_logs')
      .select('message, log_level')
      .limit(1);

    // We expect an error if the columns don't exist. We only fail if it's not the expected error.
    if (logError && !logError.message.includes('column "project_logs.message" does not exist') && !logError.message.includes('column "project_logs.log_level" does not exist')) {
        throw logError;
    } else if (logError) {
        console.error(`   ❌ FAILED: The 'project_logs' table is missing required columns: ${logError.message}`);
        allTestsPassed = false;
    }
     else {
        console.log(`   ✅ Success: 'project_logs' table contains 'message' and 'log_level' columns.`);
    }

  } catch (error) {
    console.error(`
 A critical error occurred during verification: ${error.message}`);
    allTestsPassed = false;
  }

  console.log("--- Verification Summary ---");
  if (allTestsPassed) {
    console.log(" SUCCESS: Database foundation is confirmed to be rock-solid.");
    console.log("Ready to proceed to Phase 1.2: Build Foundation Orchestrator.");
    process.exit(0);
  } else {
    console.log(" FAILURE: The database is not correctly configured. Address the errors above.");
    process.exit(1);
  }
}

verifyFoundation();