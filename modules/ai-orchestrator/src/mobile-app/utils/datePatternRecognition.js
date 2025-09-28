const DATE_PATTERNS = [
  // MM/DD/YYYY, MM-DD-YYYY
  { regex: /(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})/, format: 'MM/DD/YYYY' },
  // DD/MM/YYYY, DD-MM-YYYY (European format)
  { regex: /(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})/, format: 'DD/MM/YYYY', isEuropean: true },
  // MM/DD/YY, MM-DD-YY
  { regex: /(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2})/, format: 'MM/DD/YY' },
  // MMDDYYYY
  { regex: /(\d{2})(\d{2})(\d{4})/, format: 'MMDDYYYY' },
  // MMDDYY
  { regex: /(\d{2})(\d{2})(\d{2})/, format: 'MMDDYY' },
  // Month DD YYYY (JAN 25 2025)
  { regex: /(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\s+(\d{1,2})\s+(\d{4})/i, format: 'MMM DD YYYY' },
  // DD Month YYYY (25 JAN 2025)
  { regex: /(\d{1,2})\s+(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\s+(\d{4})/i, format: 'DD MMM YYYY' },
  // Month DD YY
  { regex: /(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\s+(\d{1,2})\s+(\d{2})/i, format: 'MMM DD YY' },
];

const EXPIRATION_KEYWORDS = [
  'best by', 'best before', 'bb', 'use by', 'use before', 
  'exp', 'expires', 'expiry', 'expiration', 'consume by',
  'display until', 'sell by', 'freeze by'
];

const MONTH_MAP = {
  'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
  'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12
};

export const extractExpirationDate = (ocrText) => {
  if (!ocrText || typeof ocrText !== 'string') {
    return { date: null, confidence: 0, rawText: null };
  }

  const normalizedText = ocrText.toUpperCase();
  
  // Check if text contains expiration keywords
  const hasExpirationKeyword = EXPIRATION_KEYWORDS.some(keyword => 
    normalizedText.includes(keyword.toUpperCase())
  );

  let bestMatch = null;
  let highestConfidence = 0;

  // Try each pattern
  for (const pattern of DATE_PATTERNS) {
    const matches = [...normalizedText.matchAll(new RegExp(pattern.regex, 'g'))];
    
    for (const match of matches) {
      const parsedDate = parseDate(match, pattern);
      
      if (parsedDate) {
        const confidence = calculateConfidence(
          match[0], 
          hasExpirationKeyword, 
          parsedDate,
          normalizedText,
          match.index
        );
        
        if (confidence > highestConfidence) {
          highestConfidence = confidence;
          bestMatch = {
            date: parsedDate,
            confidence: confidence,
            rawText: match[0]
          };
        }
      }
    }
  }

  return bestMatch || { date: null, confidence: 0, rawText: null };
};

const parseDate = (match, pattern) => {
  try {
    let day, month, year;

    switch (pattern.format) {
      case 'MM/DD/YYYY':
      case 'MM/DD/YY':
        month = parseInt(match[1], 10);
        day = parseInt(match[2], 10);
        year = parseInt(match[3], 10);
        break;
      
      case 'DD/MM/YYYY':
        if (pattern.isEuropean) {
          day = parseInt(match[1], 10);
          month = parseInt(match[2], 10);
        } else {
          month = parseInt(match[1], 10);
          day = parseInt(match[2], 10);
        }
        year = parseInt(match[3], 10);
        break;
      
      case 'MMDDYYYY':
        month = parseInt(match[1], 10);
        day = parseInt(match[2], 10);
        year = parseInt(match[3], 10);
        break;
      
      case 'MMDDYY':
        month = parseInt(match[1], 10);
        day = parseInt(match[2], 10);
        year = parseInt(match[3], 10);
        break;
      
      case 'MMM DD YYYY':
      case 'MMM DD YY':
        month = MONTH_MAP[match[1].toUpperCase()];
        day = parseInt(match[2], 10);
        year = parseInt(match[3], 10);
        break;
      
      case 'DD MMM YYYY':
        day = parseInt(match[1], 10);
        month = MONTH_MAP[match[2].toUpperCase()];
        year = parseInt(match[3], 10);
        break;
      
      default:
        return null;
    }

    // Handle 2-digit years
    if (year < 100) {
      year += year < 50 ? 2000 : 1900;
    }

    // Validate date ranges
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }

    // Create date object and check validity
    const date = new Date(year, month - 1, day);
    if (date.getMonth() !== month - 1 || date.getDate() !== day) {
      return null; // Invalid date (e.g., Feb 31)
    }

    // Return in YYYY-MM-DD format
    return `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
  } catch (error) {
    return null;
  }
};

const calculateConfidence = (matchedText, hasKeyword, parsedDate, fullText, matchIndex) => {
  let confidence = 0.5; // Base confidence

  // Boost confidence if expiration keyword is present
  if (hasKeyword) {
    confidence += 0.2;

    // Extra boost if keyword is near the date
    const nearbyText = fullText.substring(Math.max(0, matchIndex - 30), matchIndex + matchedText.length + 30);
    if (EXPIRATION_KEYWORDS.some(keyword => nearbyText.includes(keyword.toUpperCase()))) {
      confidence += 0.15;
    }
  }

  // Check if date is reasonable (not too far in past or future)
  const date = new Date(parsedDate);
  const now = new Date();
  const monthsDiff = (date - now) / (1000 * 60 * 60 * 24 * 30);
  
  if (monthsDiff > -6 && monthsDiff < 36) {
    confidence += 0.1; // Reasonable expiration range
  } else {
    confidence -= 0.2; // Suspicious date
  }

  // Boost for clear formatting
  if (matchedText.includes('/') || matchedText.includes('-')) {
    confidence += 0.05;
  }

  return Math.min(Math.max(confidence, 0), 1);
};

export const findBestExpirationDate = (ocrResults) => {
  if (!Array.isArray(ocrResults)) {
    return extractExpirationDate(ocrResults);
  }

  let bestResult = { date: null, confidence: 0, rawText: null };

  for (const text of ocrResults) {
    const result = extractExpirationDate(text);
    if (result.confidence > bestResult.confidence) {
      bestResult = result;
    }
  }

  return bestResult;
};