# Logging Specification

Each scan processed by LangChain will write an entry to `scan_log` with:
- `scan_id`: UUID from `scanned_items`
- `agent_used`: 'Claude' or 'ChatGPT'
- `confidence`: numeric OCR score
- `final_extracted_date`: extracted MM/DD/YYYY string
- `status`: 'success', 'fallback', or 'failed'
- `notes`: any explanation
- `created_at`: timestamp
