import { Camera, CameraView } from 'expo-camera';
import React, { useEffect, useRef, useState } from 'react';
import { Alert, Modal, StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import { supabase } from '../lib/supabase';
import StorageLocationPicker from './StorageLocationPicker';
import EditableReview from './EditableReview';
import scannerAPI from '../services/scannerAPI';
import { STORAGE_LOCATIONS } from '../utils/constants';
import ExpirationDateCapture from './ExpirationDateCapture';
import ManualEntryForm from './ManualEntryForm';
import OCRTestingScreen from './OCRTestingScreen';
import { WorkflowValidator } from './WorkflowValidator';

export default function BarcodeScanner({ onProductScanned }) {
  const [hasPermission, setHasPermission] = useState(null);
  const [loading, setLoading] = useState(false);
  const [showLocationPicker, setShowLocationPicker] = useState(false);
  const [showEditableReview, setShowEditableReview] = useState(false);
  const [storageLocations, setStorageLocations] = useState(STORAGE_LOCATIONS);
  const [selectedStorage, setSelectedStorage] = useState(null);
  const [scannedData, setScannedData] = useState(null);
  const [productData, setProductData] = useState(null);
  const [showScanner, setShowScanner] = useState(false);
  const [lastScannedItem, setLastScannedItem] = useState(null);
  const [showExpirationCapture, setShowExpirationCapture] = useState(false);
  const [expirationData, setExpirationData] = useState(null);
  const [currentScanId, setCurrentScanId] = useState(null);
  const [workflowStep, setWorkflowStep] = useState(null);
  const [showManualEntry, setShowManualEntry] = useState(false);
  const [showOCRTesting, setShowOCRTesting] = useState(false);
  const [showWorkflowValidator, setShowWorkflowValidator] = useState(false);
  const isProcessing = useRef(false);

  const createDefaultStorageLocations = async (locations) => {
    try {
      console.log('📝 Creating default storage locations in database...');
      for (const location of locations) {
        const { error } = await supabase
          .from('storage_locations')
          .insert(location);
        
        if (error) {
          console.error(`Failed to create location ${location.name}:`, error);
        }
      }
    } catch (error) {
      console.error('Error creating default locations:', error);
    }
  };

  useEffect(() => {
    const getCameraPermissions = async () => {
      const { status } = await Camera.requestCameraPermissionsAsync();
      setHasPermission(status === 'granted');
    };
    
    const loadStorageLocations = async () => {
      try {
        console.log('📍 Loading storage locations from Supabase...');
        const { data, error } = await supabase
          .from('storage_locations')
          .select('*')
          .order('name');
        
        if (error) {
          console.error('❌ Supabase error loading storage locations:', error);
          throw error;
        }
        
        console.log('📍 Storage locations loaded:', data);
        
        // If no data returned, use default locations
        if (!data || data.length === 0) {
          console.log('⚠️ No storage locations found, using defaults');
          const defaultLocations = [
            { id: 1, name: 'Refrigerator', description: 'Cold storage' },
            { id: 2, name: 'Freezer', description: 'Frozen storage' },
            { id: 3, name: 'Pantry', description: 'Dry goods, shelf-stable items' },
            { id: 4, name: 'Open Storage Basket', description: 'Fruits, vegetables, frequently used items' },
            { id: 5, name: 'Above Air Fryer Cabinet', description: 'Upper cabinet storage above air fryer' },
            { id: 6, name: 'Above Refrigerator Cabinet', description: 'Upper cabinet storage above refrigerator' }
          ];
          setStorageLocations(defaultLocations);
          
          // Try to create these in the database
          createDefaultStorageLocations(defaultLocations);
        } else {
          setStorageLocations(data);
        }
      } catch (error) {
        console.error('❌ Error loading storage locations:', error);
        // Use hardcoded fallback locations if database fails
        const fallbackLocations = [
          { id: 1, name: 'Refrigerator', description: 'Cold storage' },
          { id: 2, name: 'Freezer', description: 'Frozen storage' },
          { id: 3, name: 'Pantry', description: 'Dry goods, shelf-stable items' },
          { id: 4, name: 'Open Storage Basket', description: 'Fruits, vegetables, frequently used items' },
          { id: 5, name: 'Above Air Fryer Cabinet', description: 'Upper cabinet storage above air fryer' },
          { id: 6, name: 'Above Refrigerator Cabinet', description: 'Upper cabinet storage above refrigerator' }
        ];
        setStorageLocations(fallbackLocations);
      }
    };

    getCameraPermissions();
    loadStorageLocations();
  }, []);


  const handleStorageLocationSelected = async (location) => {
    setShowLocationPicker(false);
    setSelectedStorage(location.id);
    setLoading(true);

    try {
      // Step 1: Submit barcode with storage location
      const step1Result = await scannerAPI.step1Barcode(scannedData.barcode, location.id);
      
      if (step1Result.success) {
        console.log('✅ Step 1 complete, scan ID:', step1Result.scan_id);
        console.log('📦 Product:', step1Result.product);
        
        setCurrentScanId(step1Result.scan_id);
        setWorkflowStep(2);
        
        // Store product data from step 1
        if (step1Result.product) {
          setProductData({
            ...step1Result.product,
            suggested_category: step1Result.suggested_category,
            confidence_score: step1Result.confidence_score
          });
        }
        
        // Show expiration date capture for step 2
        setShowExpirationCapture(true);
      } else {
        throw new Error(step1Result.error || 'Failed to process barcode');
      }
    } catch (error) {
      console.error('❌ Step 1 error:', error);
      Alert.alert('Error', 'Failed to process product. Please try again.', [
        { text: 'OK', onPress: () => resetScanner() }
      ]);
    } finally {
      setLoading(false);
    }
  };

  const handleExpirationDateCaptured = async (dateInfo) => {
    setExpirationData(dateInfo);
    setShowExpirationCapture(false);
    setLoading(true);

    try {
      // Step 2: Submit expiration date with OCR data
      const step2Result = await scannerAPI.step2Expiration(
        currentScanId,
        dateInfo.ocrText || '',
        dateInfo.date,
        dateInfo.confidence || 0,
        dateInfo.processingTimeMs || 0
      );
      
      console.log(`⏱️ OCR processing time: ${dateInfo.processingTimeMs}ms`);

      if (step2Result.success) {
        console.log('✅ Step 2 complete, ready for review');
        // Update product data with expiration info
        setProductData(prev => ({
          ...prev,
          expiration_date: dateInfo.date,
          ocr_confidence: dateInfo.confidence,
          ocr_text: dateInfo.ocrText,
          ocr_processing_time_ms: dateInfo.processingTimeMs
        }));
        // Show review screen
        setShowEditableReview(true);
      } else {
        throw new Error(step2Result.error || 'Failed to process expiration date');
      }
    } catch (error) {
      console.error('❌ Step 2 error:', error);
      Alert.alert(
        'Error',
        'Failed to save expiration date. Would you like to retry?',
        [
          {
            text: 'Retry',
            onPress: () => setShowExpirationCapture(true)
          },
          {
            text: 'Skip',
            onPress: () => {
              // Show review without expiration date
              setProductData(prev => ({ ...prev, expiration_date: null }));
              setShowEditableReview(true);
            }
          },
          {
            text: 'Cancel',
            onPress: () => resetScanner()
          }
        ]
      );
    } finally {
      setLoading(false);
    }
  };

  const handleReviewApprove = async (correctedData) => {
    setLoading(true);

    try {
      const corrections = correctedData.manual_corrections;
      
      // Include expiration date data if available
      const dataToSubmit = {
        ...correctedData,
        expiration_date: expirationData?.date || correctedData.expiration_date,
        ocr_confidence: expirationData?.confidence,
        ocr_text: expirationData?.ocrText
      };

      // Two-step workflow - data already saved, just approve
      const result = { success: true, corrections_submitted: !!corrections };

      const selectedLocation = STORAGE_LOCATIONS.find(loc => loc.id === selectedStorage);
      const hasCorrections = result.corrections_submitted;
      
      Alert.alert(
        'Success! ✅',
        `${correctedData.name} added to ${selectedLocation?.name}${hasCorrections ? ' (with corrections)' : ''}`,
        [
          { text: 'Scan Another', onPress: () => resetScanner() },
          { text: 'Done', onPress: () => resetScanner() }
        ]
      );
      
      onProductScanned?.(correctedData);
      
    } catch (error) {
      console.error('❌ Error adding to inventory:', error);
      Alert.alert('Error', error.message || 'Failed to add to inventory', [
        { text: 'Try Again', onPress: () => setShowPreview(true) },
        { text: 'Cancel', onPress: () => resetScanner() }
      ]);
    } finally {
      setLoading(false);
    }
  };

  const handleReviewFlag = async (flagData) => {
    setLoading(true);

    try {
      const result = await scannerAPI.flagForReview(
        scannedData.scanId,
        flagData
      );

      if (!result.success) {
        throw new Error(result.error);
      }

      Alert.alert(
        'Item Flagged 🚩',
        'Item has been flagged for manual review. Thank you for your feedback!',
        [
          { text: 'Scan Another', onPress: () => resetScanner() },
          { text: 'Done', onPress: () => resetScanner() }
        ]
      );
    } catch (error) {
      console.error('❌ Error flagging item:', error);
      Alert.alert('Error', 'Failed to flag item. Please try again.');
    } finally {
      setLoading(false);
      setShowEditableReview(false);
    }
  };


  const handleBarcodeScanned = async ({ type, data }) => {
    if (isProcessing.current) return;
    
    isProcessing.current = true;
    setLoading(true);

    console.log('🔍 Barcode detected:', data);

    try {
      // Store barcode for later use
      setScannedData({ barcode: data, type });
      // Set workflow step to indicate we're in two-step mode
      setWorkflowStep(1);
      // Show storage location picker first
      setShowLocationPicker(true);
      console.log('📦 Showing storage location picker for two-step workflow');

    } catch (error) {
      console.error('❌ Scanning error:', error);
      Alert.alert('Error', 'Failed to process barcode. Please try again.', [
        { text: 'OK', onPress: () => resetScanner() }
      ]);
    }

    setLoading(false);
  };

  const handleManualEntry = (barcode) => {
    // Handle manual entry logic here
    // For now, just reset the scanner
    resetScanner();
  };

  const resetScanner = () => {
    isProcessing.current = false;
    setLoading(false);
    setShowLocationPicker(false);
    setShowEditableReview(false);
    setSelectedStorage(null);
    setScannedData(null);
    setProductData(null);
    setShowScanner(false);
    setShowExpirationCapture(false);
    setExpirationData(null);
    setCurrentScanId(null);
    setWorkflowStep(null);
    setShowManualEntry(false);
  };

  const resetToHome = () => {
    setLastScannedItem(null);
    resetScanner();
  };

  const startNewScan = () => {
    console.log('Start New Scan button pressed!');
    setShowScanner(true);
    console.log('showScanner set to true');
  };

  const testScannerAPI = async () => {
    try {
      console.log('🧪 Testing scanner API connection...');
      
      const { data: response, error } = await supabase.functions.invoke('scanner-ingest', {
        body: { 
          scan_type: 'barcode', 
          barcode: '123456789012',
          barcode_type: 'UPC',
          notes: 'API connection test'
        }
      });
      
      console.log('✅ Test API call response:', response);
      
      if (error) {
        Alert.alert('API Test Failed', 'Error: ' + error.message);
      } else {
        Alert.alert('API Test Success', 'Connected to scanner-ingest successfully!');
      }
    } catch (error) {
      console.error('❌ Test API call failed:', error);
      Alert.alert('API Test Failed', 'Error: ' + error.message);
    }
  };

  const updateStorageLocationNames = async () => {
    try {
      console.log('🏷️ Creating/updating storage locations...');
      
      // First, try to create all storage locations
      const allLocations = [
        { id: 1, name: 'Refrigerator', description: 'Cold storage' },
        { id: 2, name: 'Freezer', description: 'Frozen storage' },
        { id: 3, name: 'Pantry', description: 'Dry goods, shelf-stable items' },
        { id: 4, name: 'Open Storage Basket', description: 'Fruits, vegetables, frequently used items' },
        { id: 5, name: 'Above Air Fryer Cabinet', description: 'Upper cabinet storage above air fryer' },
        { id: 6, name: 'Above Refrigerator Cabinet', description: 'Upper cabinet storage above refrigerator' }
      ];

      // Use upsert to create or update
      const { data, error } = await supabase
        .from('storage_locations')
        .upsert(allLocations, { onConflict: 'id' })
        .select();

      if (error) {
        console.error('❌ Error upserting storage locations:', error);
        throw error;
      }

      console.log('✅ Storage locations created/updated:', data);
      Alert.alert('Success', 'Storage locations created/updated!');
      
      // Reload storage locations
      loadStorageLocations();
    } catch (error) {
      console.error('❌ Error updating storage locations:', error);
      Alert.alert('Error', 'Failed to update storage locations: ' + error.message);
    }
  };


  if (hasPermission === null) {
    return <Text>Requesting camera permission...</Text>;
  }
  if (hasPermission === false) {
    return <Text>No access to camera</Text>;
  }

  return (
    <View style={styles.container}>
      {!showScanner ? (
        // Home Screen with Start Scan Button
        <View style={styles.homeScreen}>
          <View style={styles.homeContent}>
            <Text style={styles.welcomeText}>Scanner Ready</Text>
            <Text style={styles.instructionText}>
              Tap the button below to start scanning barcodes
            </Text>
            
            <TouchableOpacity
              style={styles.startScanButton}
              onPress={startNewScan}
              activeOpacity={0.7}
            >
              <View style={styles.buttonInner}>
                <Text style={styles.startScanButtonText}>📱 Start New Scan</Text>
              </View>
            </TouchableOpacity>
            
            {/* Manual Entry Button */}
            <TouchableOpacity
              style={[styles.startScanButton, styles.manualEntryButton]}
              onPress={() => setShowManualEntry(true)}
              activeOpacity={0.7}
            >
              <View style={styles.buttonInner}>
                <Text style={styles.startScanButtonText}>✏️ Manual Entry</Text>
              </View>
            </TouchableOpacity>
            
            {/* Test API Connection Button */}
            <TouchableOpacity
              style={{ marginTop: 20, padding: 15, backgroundColor: '#007AFF', borderRadius: 10 }}
              onPress={testScannerAPI}
            >
              <Text style={{ color: 'white', fontWeight: 'bold' }}>🧪 Test API Connection</Text>
            </TouchableOpacity>
            
            {/* Update Storage Locations Button */}
            <TouchableOpacity
              style={{ marginTop: 10, padding: 15, backgroundColor: '#FF9500', borderRadius: 10 }}
              onPress={updateStorageLocationNames}
            >
              <Text style={{ color: 'white', fontWeight: 'bold' }}>🏷️ Update Location Names</Text>
            </TouchableOpacity>
            
            {/* OCR Testing Button */}
            <TouchableOpacity
              style={{ marginTop: 10, padding: 15, backgroundColor: '#8E44AD', borderRadius: 10 }}
              onPress={() => setShowOCRTesting(true)}
            >
              <Text style={{ color: 'white', fontWeight: 'bold' }}>🔬 OCR Testing Suite</Text>
            </TouchableOpacity>
            
            {/* Workflow Validator Button */}
            <TouchableOpacity
              style={{ marginTop: 10, padding: 15, backgroundColor: '#4CAF50', borderRadius: 10 }}
              onPress={() => setShowWorkflowValidator(true)}
            >
              <Text style={{ color: 'white', fontWeight: 'bold' }}>🧪 Validate Workflow</Text>
            </TouchableOpacity>
            
            {/* Debug info - remove this later */}
            <Text style={styles.debugText}>
              Debug: showScanner = {showScanner.toString()}
            </Text>
          </View>
        </View>
      ) : (
        // Scanner Screen
        <>
          <CameraView
            style={styles.camera}
            facing="back"
            onBarcodeScanned={isProcessing.current ? undefined : handleBarcodeScanned}
            barcodeScannerSettings={{
              barcodeTypes: ['upc_a', 'upc_e', 'ean13', 'ean8', 'code128', 'code39'],
            }}
          />
          
          {loading && (
            <View style={styles.overlay}>
              <Text style={styles.overlayText}>
                {isProcessing.current ? 'Processing scan...' : 'Loading...'}
              </Text>
            </View>
          )}

          <View style={styles.buttonContainer}>
            <View style={styles.buttonBackground}>
              <TouchableOpacity
                style={[
                  styles.button, 
                  isProcessing.current ? styles.buttonActive : styles.buttonReady
                ]}
                onPress={resetScanner}
                activeOpacity={0.8}
              >
                <Text style={styles.buttonText}>
                  {isProcessing.current ? '⏹ Stop Scanning' : '✕ Exit Scanner'}
                </Text>
              </TouchableOpacity>
            </View>
          </View>
        </>
      )}

      <StorageLocationPicker
        visible={showLocationPicker}
        onClose={() => setShowLocationPicker(false)}
        onSelect={handleStorageLocationSelected}
        suggestedCategory={productData?.suggested_category}
        productName={productData?.name}
      />

      <ExpirationDateCapture
        visible={showExpirationCapture}
        onClose={() => setShowExpirationCapture(false)}
        onDateCaptured={handleExpirationDateCaptured}
        productName={productData?.name}
        scanId={currentScanId}
        workflowStep={workflowStep}
      />

      <EditableReview
        visible={showEditableReview}
        onClose={() => setShowEditableReview(false)}
        onApprove={handleReviewApprove}
        onFlag={handleReviewFlag}
        productData={{
          ...productData,
          expiration_date: expirationData?.date,
          ocr_confidence: expirationData?.confidence
        }}
        selectedStorage={selectedStorage}
        loading={loading}
      />

      <ManualEntryForm
        visible={showManualEntry}
        onClose={() => setShowManualEntry(false)}
        onSuccess={(result) => {
          Alert.alert('Success', 'Product added successfully!', [
            { text: 'OK', onPress: () => resetScanner() }
          ]);
          onProductScanned?.(result);
        }}
      />

      <OCRTestingScreen
        visible={showOCRTesting}
        onClose={() => setShowOCRTesting(false)}
      />

      <Modal
        visible={showWorkflowValidator}
        animationType="slide"
        onRequestClose={() => setShowWorkflowValidator(false)}
      >
        <WorkflowValidator
          onClose={() => setShowWorkflowValidator(false)}
        />
      </Modal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  camera: {
    flex: 1,
  },
  overlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  overlayText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  buttonContainer: {
    position: 'absolute',
    bottom: 100,
    left: 20,
    right: 20,
    zIndex: 10,
  },
  buttonBackground: {
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    padding: 10,
    borderRadius: 15,
  },
  button: {
    backgroundColor: '#FF3B30',
    paddingVertical: 20,
    paddingHorizontal: 40,
    borderRadius: 10,
    alignItems: 'center',
    minHeight: 60,
  },
  buttonActive: {
    backgroundColor: '#FF9500',
  },
  buttonReady: {
    backgroundColor: '#FF3B30',
  },
  // Home Screen Styles
  homeScreen: {
    flex: 1,
    backgroundColor: '#1a1a2e',
    justifyContent: 'center',
    alignItems: 'center',
  },
  homeContent: {
    alignItems: 'center',
    padding: 40,
  },
  welcomeText: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 15,
    textAlign: 'center',
  },
  instructionText: {
    fontSize: 16,
    color: '#ccc',
    textAlign: 'center',
    marginBottom: 40,
    lineHeight: 24,
  },
  startScanButton: {
    backgroundColor: '#34C759',
    borderRadius: 15,
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    minWidth: 200,
    minHeight: 60,
  },
  manualEntryButton: {
    backgroundColor: '#007AFF',
    marginTop: 15,
  },
  buttonInner: {
    paddingVertical: 20,
    paddingHorizontal: 40,
    justifyContent: 'center',
    alignItems: 'center',
  },
  startScanButtonText: {
    color: 'white',
    fontSize: 20,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  debugText: {
    color: '#888',
    fontSize: 12,
    marginTop: 20,
    textAlign: 'center',
  },
  // Results Screen Styles
  resultsScreen: {
    flex: 1,
    backgroundColor: '#1a1a2e',
    justifyContent: 'center',
    alignItems: 'center',
  },
  resultsContent: {
    alignItems: 'center',
    padding: 30,
    width: '100%',
  },
  successTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#34C759',
    marginBottom: 30,
    textAlign: 'center',
  },
  itemCard: {
    backgroundColor: '#16213e',
    padding: 20,
    borderRadius: 15,
    width: '100%',
    marginBottom: 30,
    alignItems: 'center',
  },
  itemName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#fff',
    textAlign: 'center',
    marginBottom: 10,
  },
  itemBrand: {
    fontSize: 14,
    color: '#ccc',
    textAlign: 'center',
    marginBottom: 15,
  },
  storageInfo: {
    fontSize: 16,
    color: '#34C759',
    textAlign: 'center',
    marginBottom: 10,
  },
  timeStamp: {
    fontSize: 12,
    color: '#888',
    textAlign: 'center',
  },
  actionButtons: {
    width: '100%',
    gap: 15,
  },
  scanAnotherButton: {
    backgroundColor: '#34C759',
    paddingVertical: 18,
    paddingHorizontal: 30,
    borderRadius: 12,
    elevation: 5,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
  },
  scanAnotherButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  doneButton: {
    backgroundColor: '#6c757d',
    paddingVertical: 15,
    paddingHorizontal: 30,
    borderRadius: 12,
  },
  doneButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  buttonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
    textTransform: 'uppercase',
  },
  // Modal Styles
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    justifyContent: 'flex-start',
    alignItems: 'center',
    paddingTop: 60,
    paddingHorizontal: 20,
  },
  modalContent: {
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 20,
    width: '100%',
    maxWidth: 400,
    flex: 1,
    justifyContent: 'space-between',
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 15,
    color: '#333',
  },
  productInfo: {
    backgroundColor: '#f5f5f5',
    padding: 15,
    borderRadius: 10,
    marginBottom: 15,
    alignItems: 'center',
  },
  productName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
  },
  productBrand: {
    fontSize: 14,
    color: '#666',
    marginTop: 5,
    textAlign: 'center',
  },
  modalSubtitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 15,
    color: '#333',
    textAlign: 'center',
  },
  locationButtons: {
    flex: 1,
  },
  locationButton: {
    backgroundColor: '#f8f9fa',
    padding: 15,
    borderRadius: 10,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: '#e9ecef',
  },
  locationButtonText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#007AFF',
    textAlign: 'center',
  },
  locationDescription: {
    fontSize: 12,
    color: '#6c757d',
    textAlign: 'center',
    marginTop: 5,
  },
  cancelButton: {
    backgroundColor: '#6c757d',
    padding: 15,
    borderRadius: 10,
  },
  cancelButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  topSection: {
    flex: 1,
  },
  bottomSection: {
    paddingTop: 20,
  },
});