// src/agents/ModelExecutor.js
// Phase 2.1: Real AI Model Integration
import { ChatAnthropic } from "@langchain/anthropic";

// This initializes the real Anthropic client.
// It automatically reads the ANTHROPIC_API_KEY from the .env file.
const claude = new ChatAnthropic({
  modelName: "claude-3-5-sonnet-20240620", // Using the latest Sonnet model
  temperature: 0.3,
});

export async function callClaude(promptText) {
  try {
    console.log("🤖 Calling real Claude API...");
    const response = await claude.invoke(promptText);
    
    // The response.content is the string we need.
    const responseContent = response.content;
    console.log("✅ Claude responded successfully.");
    
    return responseContent;
    
  } catch (error) {
    console.error("❌ Claude execution failed:", error.message);
    return null;
  }
}