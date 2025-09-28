import { supabase } from '../lib/supabase';

class ScannerAPI {
  // Two-step scanner methods
  async twoStepScannerAction(action, payload) {
    try {
      console.log('🔄 Two-step scanner action:', action, payload);
      
      // Use direct fetch with the correct functions.supabase.co URL
      const functionUrl = 'https://hazopdgqiezcbwmmevqn.functions.supabase.co/two-step-scanner';
      const anonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhhem9wZGdxaWV6Y2J3bW1ldnFuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkyMzkwOTYsImV4cCI6MjA2NDgxNTA5Nn0.PKtMSX0Wv2VOk_03sfe76w1a8lhJrRVDYAyrWIZ7Stk';
      
      console.log('📍 Using direct function URL:', functionUrl);
      
      const response = await fetch(functionUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'apikey': anonKey,
          'Authorization': `Bearer ${anonKey}`
        },
        body: JSON.stringify({
          action,
          ...payload
        })
      });

      console.log('📡 Response status:', response.status);
      
      if (!response.ok) {
        const errorText = await response.text();
        console.error('❌ Function error response:', errorText);
        throw new Error(`Function call failed: ${response.status} - ${errorText}`);
      }

      const result = await response.json();
      console.log('✅ Two-step scanner response:', result);
      
      return result;
    } catch (error) {
      console.error('❌ Two-step scanner error:', error);
      console.error('Error stack:', error.stack);
      throw error;
    }
  }

  async step1Barcode(barcode, storageLocationId) {
    return this.twoStepScannerAction('step1_barcode', {
      barcode,
      storage_location_id: storageLocationId
    });
  }

  async step2Expiration(scanId, ocrText, extractedDate, confidence, processingTimeMs = 0) {
    return this.twoStepScannerAction('step2_expiration', {
      scan_id: scanId,
      ocr_text: ocrText,
      extracted_expiry_date: extractedDate,
      ocr_confidence: confidence,
      ocr_processing_time_ms: processingTimeMs
    });
  }

  async manualEntry(productData) {
    return this.twoStepScannerAction('manual_entry', {
      manual_entry_data: productData
    });
  }

  async getPendingStep2() {
    return this.twoStepScannerAction('get_pending_step2', {});
  }
  // Legacy single-step scanner (backward compatibility)
  async scanBarcode(barcode, storageLocationId, notes = '') {
    try {
      console.log('📡 Calling scanner-ingest with:', {
        barcode,
        storage_location_id: storageLocationId,
        scan_type: 'barcode'
      });

      const { data: result, error } = await supabase.functions.invoke('scanner-ingest', {
        body: {
          scan_type: 'barcode',
          barcode: barcode,
          barcode_type: 'UPC',
          storage_location_id: storageLocationId,
          notes: notes || 'Enhanced mobile scan'
        }
      });

      if (error) {
        throw error;
      }
      console.log('✅ Scanner API response:', result);

      return {
        success: true,
        data: result,
        product: result.product,
        scanId: result.scan_id,
        suggestedCategory: result.suggested_category,
        volumeInfo: result.volume_info,
        confidenceScore: result.confidence_score
      };
    } catch (error) {
      console.error('❌ Scanner API error:', error);
      return {
        success: false,
        error: error.message,
        retryable: !error.message.includes('404')
      };
    }
  }

  async addToInventory(productId, storageLocationId, quantity = 1) {
    try {
      console.log('📦 Adding to inventory:', {
        product_id: productId,
        storage_location_id: storageLocationId,
        quantity
      });

      const { data: result, error } = await supabase.functions.invoke('add-to-inventory', {
        body: {
          product_id: productId,
          storage_location_id: storageLocationId,
          quantity: quantity,
          unit: 'item',
          notes: 'Added via enhanced scanner'
        }
      });

      if (error) {
        throw error;
      }
      console.log('✅ Inventory API response:', result);

      return {
        success: true,
        data: result.data,
        message: result.message
      };
    } catch (error) {
      console.error('❌ Inventory API error:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async getProductInfo(barcode) {
    try {
      const { data, error } = await supabase
        .from('products')
        .select('*')
        .eq('barcode', barcode)
        .single();

      if (error) throw error;

      return {
        success: true,
        data: data
      };
    } catch (error) {
      console.error('❌ Product lookup error:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async retryFailedScan(scanId, updates) {
    try {
      console.log('🔄 Retrying scan:', scanId, updates);

      const { data: result, error } = await supabase.functions.invoke('scanner-review-api', {
        body: {
          action: 'update',
          scan_id: scanId,
          ...updates
        }
      });

      if (error) {
        throw error;
      }

      return {
        success: true,
        data: result
      };
    } catch (error) {
      console.error('❌ Retry scan error:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async submitCorrections(scanId, corrections) {
    try {
      console.log('📝 Submitting corrections for scan:', scanId, corrections);

      const { data: result, error } = await supabase.functions.invoke('scanner-review-api', {
        body: {
          action: 'update',
          scan_id: scanId,
          corrections: corrections,
          reviewed_by_user: true,
          review_timestamp: new Date().toISOString()
        }
      });

      if (error) {
        throw error;
      }

      console.log('✅ Corrections submitted:', result);
      return {
        success: true,
        data: result
      };
    } catch (error) {
      console.error('❌ Error submitting corrections:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async flagForReview(scanId, flagData) {
    try {
      console.log('🚩 Flagging scan for review:', scanId, flagData);

      const { data: result, error } = await supabase.functions.invoke('scanner-review-api', {
        body: {
          action: 'flag',
          scan_id: scanId,
          flag_reason: flagData.reason,
          flag_notes: flagData.notes,
          user_corrections: flagData.user_corrections,
          validation_warnings: flagData.validation_warnings,
          flagged_timestamp: new Date().toISOString()
        }
      });

      if (error) {
        throw error;
      }

      console.log('✅ Item flagged for review:', result);
      return {
        success: true,
        data: result
      };
    } catch (error) {
      console.error('❌ Error flagging item:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async addToInventoryWithCorrections(productData, storageLocationId, corrections = null) {
    try {
      console.log('📦 Adding to inventory with corrections:', {
        product_id: productData.id,
        storage_location_id: storageLocationId,
        corrections
      });

      // If we have corrections, submit them first
      if (corrections && Object.keys(corrections).length > 0) {
        const correctionResult = await this.submitCorrections(productData.scan_id, corrections);
        if (!correctionResult.success) {
          console.warn('⚠️ Failed to submit corrections, proceeding with inventory add');
        }
      }

      // Add to inventory
      const inventoryResult = await this.addToInventory(productData.id, storageLocationId, 1);
      
      return {
        success: inventoryResult.success,
        data: inventoryResult.data,
        corrections_submitted: corrections ? true : false
      };
    } catch (error) {
      console.error('❌ Error adding to inventory with corrections:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  formatErrorMessage(error) {
    if (error.includes('Network')) {
      return 'No internet connection. Please check your connection and try again.';
    } else if (error.includes('404')) {
      return 'Product not found in database. It will be added for review.';
    } else if (error.includes('401')) {
      return 'Authentication error. Please log in again.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}

export default new ScannerAPI();