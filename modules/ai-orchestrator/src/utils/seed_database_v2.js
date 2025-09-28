// src/utils/seed_database_v2.js
// This script correctly seeds the database with initial prompts and their chaining rules.

import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

// Use the SERVICE_KEY to bypass RLS for this trusted, one-time operation.
if (!process.env.SUPABASE_SERVICE_KEY) {
  throw new Error('SUPABASE_SERVICE_KEY is required to seed the database.');
}

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY, {
  auth: { persistSession: false }
});

async function getEnumValues(typeName) {
  const { data, error } = await supabase
    .rpc('get_enum_values', { type_name: typeName });

  if (error) {
    console.error(`Error fetching enum values for ${typeName}:`, error);
    return [];
  }
  return data;
}

const projectId = process.env.SCANNER_PROJECT_ID;

async function seedDatabase() {
  console.log(' Seeding database with rock-solid foundation data...');

  try {
    // Step 1: Define and insert the prompts, ensuring all not-null fields are present.
    // Using 'system_admin' as a safe, valid agent_role.
    console.log('... Inserting agent prompts...');
    const { data: prompts, error: promptError } = await supabase
      .from('agent_prompts')
      .upsert([
        .upsert([
        { project_id: projectId, agent_role: 'system_admin', prompt_title: 'Scanner Project: Context Loader', purpose: 'Initial analysis of scanner input', prompt_body: 'Analyze the input: {{input}} and determine the workflow.', version: '2.0.0', is_active: true, token_estimate: 700 },
        { project_id: projectId, agent_role: 'system_admin', prompt_title: 'Scanner Project: Barcode Validation', purpose: 'Validate barcode format and check for existence.', prompt_body: 'Validate the provided barcode: {{input}}.', version: '1.0.0', is_active: true, token_estimate: 350 },
        { project_id: projectId, agent_role: 'system_admin', prompt_title: 'Scanner Project: Expiration OCR', purpose: 'Process expiration date text from OCR.', prompt_body: 'Process OCR text: {{input}} and extract expiration date.', version: '1.0.0', is_active: true, token_estimate: 450 },
        { project_id: projectId, agent_role: 'system_admin', prompt_title: 'Scanner Project: Nutritionix Fallback', purpose: 'Handle failed Nutritionix API lookups.', prompt_body: 'Handle failed lookup for barcode: {{input}}.', version: '1.0.0', is_active: true, token_estimate: 300 }
      ], { onConflict: 'prompt_title, project_id' }) // Prevent duplicates if run again
      ], { onConflict: 'prompt_title, project_id' }) // Prevent duplicates if run again
      .select('id, prompt_title');

    if (promptError) throw promptError;
    console.log(`✅ ${prompts.length} prompts created/updated.`);

    // Step 2: Create a map of titles to their new UUIDs for easy lookup.
    const promptMap = prompts.reduce((map, p) => {
      map[p.prompt_title] = p.id;
      return map;
    }, {});

    // Step 3: Define and insert the chaining rules using the IDs from the prompts above.
    console.log('... Inserting prompt chaining rules...');
    const { data: chains, error: chainError } = await supabase
      .from('prompt_chaining_map')
      .upsert([
        { from_prompt_id: null, to_prompt_id: promptMap['Scanner Project: Context Loader'], condition: { 'start_prompt': true }, notes: 'Official start of the scanner workflow.' },
        { from_prompt_id: promptMap['Scanner Project: Barcode Validation'], to_prompt_id: promptMap['Scanner Project: Expiration OCR'], condition: { 'next_action': 'proceed_to_expiration_scan' }, notes: 'On successful validation, proceed to OCR.' },
        { from_prompt_id: promptMap['Scanner Project: Barcode Validation'], to_prompt_id: promptMap['Scanner Project: Nutritionix Fallback'], condition: { 'validation_status': 'failed' }, notes: 'On failed validation, use fallback.' }
      ], { onConflict: 'from_prompt_id, to_prompt_id' }); // Prevent duplicates

    if (chainError) throw chainError;
    console.log('✅ Chaining rules created.');

    console.log('\n Database seeding complete! Foundation is solid.');

  } catch (error) {
    console.error('❌ Error seeding database:', error.message);
    process.exit(1);
  }
}

seedDatabase();