# Uzhavan - Smart Agriculture App

## Quick Setup

### 1. Get Gemini API Key
Get your API key from: https://aistudio.google.com/app/apikey

### 2. Add API Key in 2 Places

**Flutter App:**
```
lib/services/gemini_api_service.dart (line 7-8)
```
Replace the existing key with your new key

**Server:**
```
server/.env
```
Update: `GEMINI_API_KEY=YOUR_API_KEY_HERE`

### 3. Update Firebase Rules
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **agriapp-59c85**
3. Firestore Database → Rules
4. Add:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```
5. Publish

### 4. Run Server
```bash
cd server
npm install
node server.js
```

### 5. Run Flutter App
```bash
flutter run
```

## Features
- AI-powered daily farming nudges (Tamil)
- Weather monitoring
- Soil mineral tracking
- Tamil chatbot assistant
