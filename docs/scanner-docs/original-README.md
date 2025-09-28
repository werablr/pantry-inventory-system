# Scanner LangChain Enhancer

## Purpose
Adds Claude + ChatGPT fallback logic to your existing scanner app using LangChain.

## Setup
1. Copy `.env.sample` → `.env` and fill in your keys
2. Create `scan_log` table using `supabase_schema/scan_log.sql`
3. Run `python langchain_ocr_fix.py`

## Modes
- `--test`: dry run
- `--once`: process one scan
- `--scheduled`: continuous scan processing (for cron)
