// scanner_foundation_orchestrator.js
// Final Version for Phase 2.2
// Includes robust DB query and strict JSON output enforcement.

import { createClient } from '@supabase/supabase-js';
import { callClaude } from "./ModelExecutor.js";

const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);

class ScannerOrchestrator {
  constructor() {
    this.projectId = process.env.SCANNER_PROJECT_ID;
  }

  // --- Data Retrieval Methods (with final fix) ---

  async getProjectDetails() {
    console.log("    Retrieving project details...");
    const { data, error } = await supabase
      .from('projects')
      .select('project_name, created_at')
      .eq('id', this.projectId); // .single() REMOVED for robustness

    if (error) {
      console.error("    ❌ Database query failed:", error.message);
      return { error: error.message };
    }

    if (!data || data.length !== 1) {
      const errorMessage = `Expected 1 project for ID ${this.projectId}, but found ${data ? data.length : 0}. Check SCANNER_PROJECT_ID in .env file.`;
      console.error(`    ❌ ${errorMessage}`);
      return { error: errorMessage };
    }

    console.log("    ✅ Project details retrieved.");
    return data[0]; // Return the single project object
  }

  async getRecentLogs(limit = 5) {
    console.log(`   Retrieving last ${limit} logs...`);
    const { data, error } = await supabase
      .from('project_logs')
      .select('created_at, log_title, session_date')
      .eq('project_id', this.projectId)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) {
      console.error(`    ❌ Failed to get recent logs:`, error.message);
      return { error: error.message };
    }
    console.log(`    ✅ ${data.length} logs retrieved.`);
    return data;
  }


  // --- Core Chaining Logic ---

  async loadChainStart() {
    console.log(" Finding workflow start point...");
    const { data, error } = await supabase
      .from('prompt_chaining_map')
      .select(`
        to_prompt_id,
        condition,
        notes,
        to_prompt:agent_prompts!prompt_chaining_map_to_prompt_id_fkey(id, prompt_title, prompt_body)
      `)
      .eq('condition->>start_prompt', 'true')
      .single();

    if (error) throw error;
    if (!data) throw new Error("No workflow start point found in database.");

    console.log(`✅ Found start point: ${data.to_prompt.prompt_title}`);
    return data;
  }

  async findNextStep(fromPromptId, output) {
    const { data, error } = await supabase
      .from('prompt_chaining_map')
      .select(`
        condition,
        notes,
        to_prompt:agent_prompts!prompt_chaining_map_to_prompt_id_fkey(id, prompt_title, prompt_body)
      `)
      .eq('from_prompt_id', fromPromptId);

    if (error) throw error;
    if (!data || data.length === 0) return null;

    for (const chain of data) {
      const condition = chain.condition || {};
      let matches = true;
      for (const [key, expectedValue] of Object.entries(condition)) {
        if (key === 'start_prompt') continue;
        if (output[key] !== expectedValue) {
          matches = false;
          break;
        }
      }
      if (matches) {
        console.log(`✅ Condition matched: ${chain.notes || 'Proceeding'}`);
        console.log(`➡️  Next prompt: ${chain.to_prompt.prompt_title}`);
        return chain.to_prompt;
      }
    }
    return null;
  }

  // --- Main Workflow Execution ---

  async executeWorkflow(input) {
    try {
      console.log("\n Starting Scanner Project Workflow");
      const startPoint = await this.loadChainStart();
      let currentPrompt = startPoint.to_prompt;
      let currentInput = input;
      let stepCount = 0;

      while (currentPrompt && stepCount < 10) {
        stepCount++;
        console.log(`\n---  Step ${stepCount}: ${currentPrompt.prompt_title} ---`);

        let promptTextForAI;

        if (currentPrompt.prompt_title === "Scanner Project: Context Loader") {
            console.log("  Enriching prompt with dynamic context...");
            const projectDetails = await this.getProjectDetails();
            const recentLogs = await this.getRecentLogs();

            promptTextForAI = `
              You are a system service that only returns JSON. Do not include any human-readable text, greetings, or explanations outside of the JSON structure.

              CONTEXT:
              - Project Details: ${JSON.stringify(projectDetails, null, 2)}
              - Recent Logs: ${JSON.stringify(recentLogs, null, 2)}
              - Current Input: ${JSON.stringify(currentInput, null, 2)}

              TASK:
              Analyze the provided CONTEXT and perform the following task based on the original prompt body: "${currentPrompt.prompt_body}".

              Your response MUST be a single, valid JSON object.
            `;
        } else {
            promptTextForAI = `
              You are a system service that only returns JSON. Do not include any human-readable text, greetings, or explanations outside of the JSON structure.

              CONTEXT:
              - Previous Step Input: ${JSON.stringify(currentInput, null, 2)}

              TASK:
              Perform the following task based on the original prompt body: "${currentPrompt.prompt_body}".

              Your response MUST be a single, valid JSON object.
            `;
        }

        const rawAiResponse = await callClaude(promptTextForAI);
        if (!rawAiResponse) throw new Error("AI model returned a null response.");

        console.log("📤 Raw AI Response:", rawAiResponse);

        let parsedOutput;
        try {
          parsedOutput = JSON.parse(rawAiResponse);
          console.log("  Parsed AI Output:", parsedOutput);
        } catch (e) {
          console.error("  ❌ AI response was not valid JSON. Workflow cannot continue.", e.message);
          throw new Error("AI response was not valid JSON.");
        }

        const nextStep = await this.findNextStep(currentPrompt.id, parsedOutput);

        if (nextStep) {
          currentPrompt = nextStep;
          currentInput = { ...currentInput, ...parsedOutput };
        } else {
          console.log("\n✅ Workflow completed successfully!");
          return { success: true, finalOutput: parsedOutput, totalSteps: stepCount };
        }
      }
      if (stepCount >= 10) throw new Error("Workflow exceeded max steps.");
    } catch (error) {
      console.error("\n❌ Workflow execution failed:", error.message);
      return { success: false, error: error.message };
    }
  }
}

// --- CLI Interface ---
async function main() {
  const inputArg = process.argv[2];
  if (!inputArg) {
    console.error("Please provide a JSON input string. Example: '{\"barcode\":\"12345\"}'");
    process.exit(1);
  }
  
  try {
    const parsedInput = JSON.parse(inputArg);
    const orchestrator = new ScannerOrchestrator();
    const result = await orchestrator.executeWorkflow(parsedInput);

    console.log("\n" + "=".repeat(60));
    console.log(" WORKFLOW RESULT");
    console.log("=".repeat(60));
    console.log(JSON.stringify(result, null, 2));

    if (!result.success) {
      console.log("\n❌ Workflow failed - check logs above");
    }

  } catch (error) {
    console.error("❌ Orchestrator startup failed:", error.message);
    process.exit(1);
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

