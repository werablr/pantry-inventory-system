// Scanner Project Runtime Orchestrator
// Production code that reads from Supabase and executes Scanner Project workflows

import { ChatAnthropic } from "@langchain/anthropic";
import { ChatOpenAI } from "@langchain/openai";
import { ChatGoogleGenerativeAI } from "@langchain/google-genai";
import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";

// Load environment variables
dotenv.config();

// Model configuration with fallback chain
const MODEL_CONFIG = {
  claude: {
    name: process.env.CLAUDE_MODEL || "claude-4-sonnet",
    provider: "anthropic",
    cost_per_token: 0.000003,
    specialties: ["backend", "database", "analysis", "prompts"]
  },
  gpt4o: {
    name: process.env.GPT_MODEL || "gpt-4o",
    provider: "openai", 
    cost_per_token: 0.000015,
    specialties: ["frontend", "ui", "planning", "verification"]
  },
  gemini: {
    name: process.env.GEMINI_MODEL || "gemini-1.5-pro",
    provider: "google",
    cost_per_token: 0.000002,
    specialties: ["fact_check", "research", "verification"]
  }
};

// Initialize AI models
const models = {
  claude: new ChatAnthropic({
    modelName: MODEL_CONFIG.claude.name,
    temperature: 0,
    apiKey: process.env.ANTHROPIC_API_KEY
  }),
  gpt4o: new ChatOpenAI({
    modelName: MODEL_CONFIG.gpt4o.name,
    temperature: 0,
    apiKey: process.env.OPENAI_API_KEY
  }),
  gemini: new ChatGoogleGenerativeAI({
    modelName: MODEL_CONFIG.gemini.name,
    temperature: 0,
    apiKey: process.env.GOOGLE_API_KEY
  })
};

// Supabase client
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);

// Model executor with automatic fallback
class ModelExecutor {
  constructor() {
    this.usageLog = [];
  }

  async executeWithFallback(prompt, taskDescription, context = {}) {
    const fallbackOrder = ["claude", "gpt4o", "gemini"];
    
    for (const modelKey of fallbackOrder) {
      try {
        const model = models[modelKey];
        const startTime = Date.now();
        
        console.log(`🤖 Trying ${MODEL_CONFIG[modelKey].name}...`);
        const response = await model.invoke(prompt);
        
        const duration = Date.now() - startTime;
        const estimatedTokens = response.content.length / 4;
        const estimatedCost = estimatedTokens * MODEL_CONFIG[modelKey].cost_per_token;
        
        // Log successful execution
        this.usageLog.push({
          model: modelKey,
          success: true,
          duration,
          estimatedTokens,
          estimatedCost,
          task: taskDescription.substring(0, 100),
          timestamp: new Date().toISOString()
        });

        console.log(`✅ Success with ${MODEL_CONFIG[modelKey].name} (${duration}ms)`);
        
        return {
          content: response.content,
          model: modelKey,
          duration,
          estimatedCost
        };
        
      } catch (error) {
        console.log(`❌ Failed with ${MODEL_CONFIG[modelKey].name}: ${error.message}`);
        
        this.usageLog.push({
          model: modelKey,
          success: false,
          error: error.message,
          task: taskDescription.substring(0, 100),
          timestamp: new Date().toISOString()
        });
        
        continue;
      }
    }
    
    throw new Error("All models failed to execute the task");
  }

  getUsageReport() {
    const totalCost = this.usageLog.reduce((sum, log) => sum + (log.estimatedCost || 0), 0);
    const successRate = this.usageLog.filter(log => log.success).length / this.usageLog.length;
    
    return {
      totalRequests: this.usageLog.length,
      successfulRequests: this.usageLog.filter(log => log.success).length,
      successRate: (successRate * 100).toFixed(2) + "%",
      totalEstimatedCost: totalCost.toFixed(6),
      recentUsage: this.usageLog.slice(-5)
    };
  }
}

// Main Scanner Project Orchestrator
class ScannerProjectOrchestrator {
  constructor() {
    this.modelExecutor = new ModelExecutor();
  }

  async loadProjectContext() {
    try {
      console.log("📊 Loading Scanner Project context from Supabase...");
      
      // Load recent conversation memory (since project_logs doesn't exist)
      const { data: recentLogs } = await supabase
        .from("conversation_memory")
        .select("*")
        .order("created_at", { ascending: false })
        .limit(5);

      // Since agent_prompts doesn't exist, return empty array
      const activePrompts = [];

      console.log(`✅ Loaded ${recentLogs?.length || 0} recent logs and ${activePrompts?.length || 0} active prompts`);

      return {
        recentLogs: recentLogs || [],
        activePrompts: activePrompts || [],
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      console.log(`⚠️ Could not load full project context: ${error.message}`);
      return { error: error.message, timestamp: new Date().toISOString() };
    }
  }

  async loadPromptChain() {
    try {
      console.log("🔗 Using default Scanner Project workflow...");
      
      // Since we don't have the prompt_chaining_map table yet, use a hardcoded workflow
      const defaultChain = {
        id: 1,
        start_prompt: true,
        next_prompt: "Scanner Project: Context Loader",
        sequence: 1
      };

      console.log(`✅ Using default chain: ${defaultChain.next_prompt}`);
      return defaultChain;
    } catch (error) {
      console.log(`❌ Failed to load prompt chain: ${error.message}`);
      throw error;
    }
  }

  async loadPromptByTitle(promptTitle) {
    try {
      console.log(`🔍 Loading prompt: ${promptTitle}`);
      
      // Since we don't have agent_prompts table yet, use a hardcoded Context Loader prompt
      if (promptTitle === "Scanner Project: Context Loader") {
        return {
          prompt_title: "Scanner Project: Context Loader",
          prompt_body: `You are the Scanner Project Context Loader. Your job is to analyze the input and provide context for the Scanner Project workflow.

Input received: {{input}}

Please analyze this input and provide:
1. Input type (barcode, image, text, etc.)
2. Expected workflow path
3. Initial validation
4. Context for next steps

Be thorough and structured in your response.`
        };
      }
      
      throw new Error(`Prompt "${promptTitle}" not found in hardcoded prompts`);
    } catch (error) {
      console.log(`❌ Could not load prompt "${promptTitle}": ${error.message}`);
      throw error;
    }
  }

  async logExecution(step, status, content, metadata = {}) {
    try {
      // Try to log to conversation_memory table since that exists
      await supabase.from("conversation_memory").insert({
        memory_text: `Scanner Project: ${step} - ${status}`,
        summary: content.substring(0, 500),
        context: JSON.stringify(metadata)
      });
      console.log(`📝 Logged: ${step} - ${status}`);
    } catch (error) {
      console.log(`⚠️ Could not log execution: ${error.message}`);
    }
  }

  async executeWorkflow(input) {
    try {
      console.log(`\n🚀 Starting Scanner Project workflow with input: ${JSON.stringify(input)}`);
      
      // Step 1: Load project context
      const context = await this.loadProjectContext();
      
      // Step 2: Load the prompt chain starting point
      const startingChain = await this.loadPromptChain();
      
      // Step 3: Load the Context Loader prompt
      const contextLoaderPrompt = await this.loadPromptByTitle("Scanner Project: Context Loader");
      
      console.log(`\n🎯 Executing: ${contextLoaderPrompt.prompt_title}`);
      console.log(`📝 Prompt: ${contextLoaderPrompt.prompt_body.substring(0, 200)}...`);
      
      // Step 4: Execute the Context Loader with input
      const promptWithInput = contextLoaderPrompt.prompt_body.replace(/\{\{input\}\}/g, JSON.stringify(input));
      
      const result = await this.modelExecutor.executeWithFallback(
        promptWithInput,
        "Scanner Project Context Loader",
        { input, context }
      );
      
      // Step 5: Log the execution
      await this.logExecution(
        contextLoaderPrompt.prompt_title,
        "success",
        result.content,
        {
          model: result.model,
          duration: result.duration,
          estimatedCost: result.estimatedCost,
          input: JSON.stringify(input)
        }
      );
      
      // Step 6: Return comprehensive results
      const finalReport = {
        workflow: "Scanner Project Context Loader",
        input: input,
        result: result.content,
        execution: {
          model: result.model,
          duration: result.duration,
          estimatedCost: result.estimatedCost
        },
        context: context,
        usageReport: this.modelExecutor.getUsageReport(),
        timestamp: new Date().toISOString(),
        success: true
      };
      
      console.log(`\n✅ Workflow completed successfully!`);
      console.log(`📊 Model used: ${result.model}`);
      console.log(`⏱️ Duration: ${result.duration}ms`);
      console.log(`💰 Estimated cost: $${result.estimatedCost.toFixed(6)}`);
      
      return finalReport;
      
    } catch (error) {
      console.error(`❌ Workflow execution failed: ${error.message}`);
      
      await this.logExecution(
        "workflow_error",
        "error", 
        error.message,
        { input: JSON.stringify(input), error: error.toString() }
      );
      
      throw error;
    }
  }
}

// CLI Interface
async function main() {
  const input = process.argv[2] || '{"barcode":"078742133121"}';
  
  try {
    console.log("🔧 Scanner Project Runtime Orchestrator v2.0");
    console.log("🔗 Connecting to Supabase...");
    console.log(`📋 Project ID: ${process.env.SCANNER_PROJECT_ID}`);
    
    const parsedInput = JSON.parse(input);
    
    const orchestrator = new ScannerProjectOrchestrator();
    const result = await orchestrator.executeWorkflow(parsedInput);
    
    console.log("\n📋 FINAL WORKFLOW RESULT:");
    console.log("=" .repeat(50));
    console.log(result.result);
    console.log("=" .repeat(50));
    
    if (process.argv.includes("--verbose")) {
      console.log("\n📊 Full Report:");
      console.log(JSON.stringify(result, null, 2));
    }
    
  } catch (error) {
    console.error("❌ Orchestrator failed:", error.message);
    process.exit(1);
  }
}

// Export for use in other modules
export { ScannerProjectOrchestrator, ModelExecutor };

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}