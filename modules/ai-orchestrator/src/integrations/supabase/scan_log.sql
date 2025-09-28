CREATE TABLE IF NOT EXISTS scan_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scan_id UUID NOT NULL,
    agent_used TEXT NOT NULL,
    confidence FLOAT,
    final_extracted_date TEXT,
    status TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);
