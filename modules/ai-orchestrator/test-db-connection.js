// test-db-connection.js
// Phase 1.1: Verify Database Connection
// This script tests access to Scanner Project tables in Supabase

import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);

async function testDatabaseConnection() {
  console.log(' Phase 1.1: Database Connection Test');
  console.log(' Project ID:', process.env.SCANNER_PROJECT_ID);
  console.log(' Supabase URL:', process.env.SUPABASE_URL?.substring(0, 30) + '...');
  console.log('');

  try {
    // Test 1: Check agent_prompts table
    console.log(' Testing agent_prompts table...');
    const { data: prompts, error: promptError } = await supabase
      .from('agent_prompts')
      .select('prompt_title, purpose, prompt_body')
      .eq('project_id', process.env.SCANNER_PROJECT_ID)
      .eq('is_active', true);
    if (promptError) {
      console.error('❌ agent_prompts error:', promptError.message);
      return false;
    }
    
    console.log(`✅ Found ${prompts.length} active Scanner Project prompts:`);
    prompts.forEach(prompt => {
      console.log(`   - ${prompt.prompt_title} (${prompt.purpose})`);
    });
    console.log('');

    // Test 2: Check prompt_chaining_map table
    console.log(' Testing prompt_chaining_map table...');
    const { data: chains, error: chainError } = await supabase
      .from('prompt_chaining_map')
      .select('from_prompt_id, to_prompt_id, condition, notes')
      .limit(10);
    if (chainError) {
      console.error('❌ prompt_chaining_map error:', chainError.message);
      return false;
    }
    
    console.log(`✅ Found ${chains.length} chaining rules:`);
    chains.forEach(chain => {
      console.log(`   - ${chain.notes || 'No notes'} (${chain.from_prompt_id} → ${chain.to_prompt_id})`);
    });
    console.log('');
    
    // Test 3: Find workflow start point
    console.log(' Testing for workflow start point...');
    const { data: startChains, error: startError } = await supabase
      .from('prompt_chaining_map')
      .select('to_prompt_id, condition, notes')
      .eq('condition->start_prompt', true);
    if (startError) {
      console.error('❌ Start point search error:', startError.message);
      return false;
    }
    
    if (startChains.length === 0) {
      console.log('⚠️ No workflow start point found (condition->start_prompt = true)');
      console.log(' This will need to be created in the database');
    } else {
      console.log(`✅ Found ${startChains.length} workflow start point(s):`);
      startChains.forEach(chain => {
        console.log(`   - ${chain.notes} (to_prompt_id: ${chain.to_prompt_id})`);
      });
    }
    console.log('');
    
    // Test 4: Check project_logs table (for logging capability)
    console.log(' Testing project_logs table...');
    const { data: logs, error: logError } = await supabase
      .from('project_logs')
      .select('log_level, message')
      .eq('project_id', process.env.SCANNER_PROJECT_ID)
      .limit(3);
    if (logError) {
      console.log('⚠️ project_logs table not accessible:', logError.message);
      console.log(' Will use alternative logging method');
    } else {
      console.log(`✅ project_logs table accessible (${logs.length} recent entries)`);
    }
    console.log('');

    console.log(' DATABASE CONNECTION TEST PASSED');
    console.log('✅ All required tables are accessible');
    console.log(' Ready to proceed to Phase 1.2: Foundation Orchestrator');
    return true;
    
  } catch (error) {
    console.error('❌ DATABASE CONNECTION TEST FAILED:', error.message);
    return false;
  }
}

// Run the test
testDatabaseConnection()
  .then(success => {
    if (success) {
      console.log('');
      console.log('Phase 1.1 COMPLETE - Database connection verified');
      process.exit(0);
    } else {
      console.log('');
      console.log('Phase 1.1 FAILED - Fix database issues before proceeding');
      process.exit(1);
    }
  })
  .catch(error => {
    console.error(' Test script error:', error.message);
    process.exit(1);
  });