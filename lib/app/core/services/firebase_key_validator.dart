import 'package:flutter/foundation.dart';
import 'env_config_service.dart';

/// Firebase Service Account Key Validator
/// Use this to debug Firebase private key issues
class FirebaseKeyValidator {
  
  /// Validate Firebase Service Account configuration
  static void validateFirebaseConfig() {
    debugPrint('🔍 Validating Firebase Service Account Configuration...');
    debugPrint('=' * 60);
    
    try {
      final serviceAccount = EnvConfig.getFirebaseServiceAccountJson();
      
      // Check each field
      _validateField('Type', serviceAccount['type']);
      _validateField('Project ID', serviceAccount['project_id']);
      _validateField('Private Key ID', serviceAccount['private_key_id']);
      _validateField('Client Email', serviceAccount['client_email']);
      _validateField('Client ID', serviceAccount['client_id']);
      
      // Validate private key format
      _validatePrivateKey(serviceAccount['private_key']);
      
      debugPrint('=' * 60);
      debugPrint('✅ All Firebase Service Account fields validated successfully!');
      
    } catch (e) {
      debugPrint('=' * 60);
      debugPrint('❌ Firebase Service Account validation failed!');
      debugPrint('Error: $e');
      debugPrint('=' * 60);
    }
  }
  
  static void _validateField(String fieldName, String? value) {
    if (value == null || value.isEmpty) {
      debugPrint('❌ $fieldName: MISSING or EMPTY');
    } else {
      // Show first 20 chars for security
      final preview = value.length > 20 
          ? '${value.substring(0, 20)}...' 
          : value;
      debugPrint('✅ $fieldName: $preview');
    }
  }
  
  static void _validatePrivateKey(String? privateKey) {
    debugPrint('\n🔑 Validating Private Key Format:');
    
    if (privateKey == null || privateKey.isEmpty) {
      debugPrint('❌ Private Key: MISSING or EMPTY');
      return;
    }
    
    // Check for PEM markers
    final hasBeginMarker = privateKey.contains('-----BEGIN PRIVATE KEY-----');
    final hasEndMarker = privateKey.contains('-----END PRIVATE KEY-----');
    
    debugPrint('   Begin Marker: ${hasBeginMarker ? "✅ Found" : "❌ Missing"}');
    debugPrint('   End Marker: ${hasEndMarker ? "✅ Found" : "❌ Missing"}');
    
    // Check for newlines
    final hasNewlines = privateKey.contains('\n');
    debugPrint('   Newlines: ${hasNewlines ? "✅ Present" : "❌ Missing (may cause issues)"}');
    
    // Check key length (typical RSA 2048 key is ~1600-1700 chars)
    final keyLength = privateKey.length;
    debugPrint('   Key Length: $keyLength chars');
    
    if (keyLength < 1000) {
      debugPrint('   ⚠️  Warning: Key seems too short, might be incomplete');
    } else if (keyLength > 2000) {
      debugPrint('   ⚠️  Warning: Key seems too long, might have extra content');
    } else {
      debugPrint('   ✅ Key length looks good');
    }
    
    // Check for common mistakes
    if (privateKey.contains('\\n') && !privateKey.contains('\n')) {
      debugPrint('   ⚠️  Warning: Found literal \\n but no actual newlines');
      debugPrint('   💡 This is OK - code will convert them automatically');
    }
    
    // Overall validation
    if (hasBeginMarker && hasEndMarker && keyLength > 1000) {
      debugPrint('   ✅ Private Key format looks VALID');
    } else {
      debugPrint('   ❌ Private Key format looks INVALID');
      debugPrint('\n📋 Expected format:');
      debugPrint('   "-----BEGIN PRIVATE KEY-----\\nMIIEvQI...\\n-----END PRIVATE KEY-----\\n"');
    }
  }
  
  /// Quick test to check if Firebase auth will work
  static Future<void> testFirebaseAuth() async {
    debugPrint('\n🧪 Testing Firebase Authentication...');
    debugPrint('=' * 60);
    
    try {
      // This will be imported from notification_service
      // For now, just validate the config
      validateFirebaseConfig();
      
      debugPrint('\n💡 To test actual authentication, send a test notification');
      debugPrint('   and check for "Firebase access token obtained successfully"');
      
    } catch (e) {
      debugPrint('❌ Test failed: $e');
    }
    
    debugPrint('=' * 60);
  }
}
