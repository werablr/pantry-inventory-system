# QUICK FIX FOR NUTRITION SCANNER

## Problem Identified:
1. Users aren't completing Step 2 (expiration scanning) - leaving scans stuck at Step 1
2. Date extraction failing even with high OCR confidence
3. No fallback when OCR fails

## Immediate Fixes:

### 1. Add Skip Option in ExpirationDateCapture.js:
Add a "Skip" button that allows users to complete Step 2 without expiration date:

```javascript
const handleSkipExpiration = async () => {
  // Submit Step 2 with no date
  const result = await scannerAPI.step2Expiration(
    scanId,
    'User skipped expiration scanning',
    null, // no date
    0,    // no confidence
    0     // no processing time
  );
  onDateCaptured({ date: null, confidence: 0, ocrText: 'Skipped by user' });
};
```

### 2. Fix Date Extraction in utils/datePatternRecognition.js:
Add more fallback patterns and fix the parsing logic.

### 3. Auto-advance Workflow:
If OCR fails after 3 attempts, auto-advance to review with no expiration date.

## Testing Commands:
Test the current stuck scans:

```bash
# Complete Step 2 for stuck scans
curl -X POST https://hazopdgqiezcbwmmevqn.functions.supabase.co/two-step-scanner \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "action": "step2_expiration",
    "scan_id": 142,
    "ocr_text": "Manual completion",
    "extracted_expiry_date": null,
    "ocr_confidence": 0
  }'
```

## Root Cause:
The system IS working - users just aren't finishing the two-step workflow. Need better UX to force completion or allow skipping.
