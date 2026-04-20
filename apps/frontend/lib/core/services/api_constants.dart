// --- PRODUCTION URLs ---
const String kProdBaseUrl = 'https://truth-lens-backend-aa7e.onrender.com/api';
const String kProdMlUrl   = 'https://truth-lens-ml.onrender.com'; // Placeholder if needed

// --- LOCAL URLs (10.0.2.2 = host localhost for Android Emulator) ---
const String kLocalBaseUrl = 'http://10.0.2.2:8000/api';
const String kLocalMlUrl   = 'http://10.0.2.2:10000';

// Current active selection (managed by ApiConfig now, but kept for reference)
const String kBaseUrl = kProdBaseUrl;
const String kMlServiceUrl = kLocalMlUrl;
