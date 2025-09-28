# Food Management System

**🍳 Unified food and kitchen management ecosystem with modular architecture**

## 🏗️ System Architecture

This is a modular food management system designed for extensibility and future expansion.

### Core Modules

#### `modules/web-interface/`
**CSV Import & Inventory Management**
- Professional 306-item inventory management with Supabase automation
- 75%+ automatic ingredient mapping through learning system
- Drag-and-drop CSV upload interface with real-time progress tracking
- **Status**: ✅ Production Ready

#### `modules/scanner-mobile/`
**React Native Barcode Scanner**
- Expo-based mobile app for barcode scanning (UPC, EAN, Code128)
- Real-time nutritional data lookup via Nutritionix API
- Offline capability with sync when connected
- Storage location management and quantity tracking
- **Status**: 🔄 Integration Phase

#### `modules/ai-orchestrator/`
**LangChain AI Processing**
- Claude + ChatGPT fallback for OCR and text recognition
- AI-powered food item identification and categorization
- Confidence scoring with user approval workflow
- **Status**: 🔄 Integration Phase

#### `modules/recipe-manager/`
**Recipe Database & Management**
- Recipe storage and organization
- Meal planning integration
- Nutritional analysis capabilities
- **Status**: 📋 Planning Phase

## 🚀 Quick Start

### Web Interface (Ready Now)
1. Open `modules/web-interface/index.html` in your browser
2. Configure your Supabase project URL and API key
3. Upload your 306-item inventory CSV
4. Watch the system automatically categorize ingredients

### Mobile Scanner (Coming Soon)
1. Navigate to `modules/scanner-mobile/`
2. Run `npm install && expo start`
3. Scan barcodes to add items to inventory
4. Items sync with web interface automatically

## 🔧 Configuration

### Supabase Setup
- **Project URL**: Your Supabase project endpoint
- **API Key**: Anon public key for client access
- **Database**: PostgreSQL with automated ingredient mapping

### API Integrations
- **Nutritionix**: For nutritional data lookup
- **OpenAI/Claude**: For AI-powered categorization

## 📊 Expected Performance
- **Import Speed**: 306 items in ~30 seconds
- **Auto-Approval**: 75%+ on first import, 90%+ as system learns
- **Scanner Speed**: Real-time barcode recognition
- **AI Accuracy**: High-confidence ingredient categorization

## 🛠️ Future Modules (Planned)
- **Kitchen Kiosk**: Raspberry Pi display interface
- **Voice Commands**: Alexa/Google Assistant integration
- **Meal Planning**: AI-powered meal suggestions
- **Shopping Lists**: Automated grocery planning
- **Expiration Tracking**: Smart notification system

## 📁 Directory Structure
```
food-management-system/
├── modules/
│   ├── web-interface/          # CSV import & web dashboard
│   ├── scanner-mobile/         # React Native barcode scanner
│   ├── ai-orchestrator/        # LangChain AI processing
│   └── recipe-manager/         # Recipe database & planning
├── docs/
│   ├── original-README.md      # Original inventory system docs
│   └── scanner-docs/           # Detailed scanner documentation
└── README.md                   # This file
```

## 🔗 Integration Points
- **Web ↔ Mobile**: Shared Supabase database
- **Scanner ↔ AI**: Automated ingredient recognition
- **Inventory ↔ Recipes**: Smart meal planning
- **All Modules**: Unified ingredient master database

## 🎯 Vision
A comprehensive food ecosystem that learns your preferences, automates inventory management, suggests recipes based on available ingredients, and scales from mobile scanning to whole-house kitchen automation.

---
**Built with**: Supabase, React Native, LangChain, Vanilla JavaScript
**Last Updated**: September 28, 2025