import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Secure Storage Service
/// Handles all sensitive data storage using encrypted storage
/// Use this for: tokens, user credentials, sensitive user data
class SecureStorageService {
  // Singleton pattern
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // Storage instance with encryption options
  late final FlutterSecureStorage _storage;

  /// Initialize secure storage
  Future<void> init() async {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
  }

  // Storage Keys - Centralized key management
  static const String _keyAuthToken = 'auth_token';
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserPic = 'user_pic';
  static const String _keyUserPassword = 'user_password';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserRoleId = 'user_role_id';
  static const String _keyIsUserLoggedIn = 'is_user_logged_in';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyLastLoginTime = 'last_login_time';
  static const String _keyFCMToken = 'fcm_token';

  // App preferences keys
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const String _keyFirstInstall = 'first_install';

  // ==================== Auth Token Methods ====================

  /// Save authentication token
  Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _keyAuthToken, value: token);
      debugPrint('✅ Auth token saved securely');
    } catch (e) {
      debugPrint('❌ Error saving auth token: $e');
      rethrow;
    }
  }

  /// Get authentication token
  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _keyAuthToken);
    } catch (e) {
      debugPrint('❌ Error reading auth token: $e');
      return null;
    }
  }

  /// Delete authentication token
  Future<void> deleteAuthToken() async {
    try {
      await _storage.delete(key: _keyAuthToken);
      debugPrint('🗑️ Auth token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting auth token: $e');
    }
  }

  // ==================== Refresh Token Methods ====================

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: token);
    } catch (e) {
      debugPrint('❌ Error saving refresh token: $e');
      rethrow;
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e) {
      debugPrint('❌ Error reading refresh token: $e');
      return null;
    }
  }

  // ==================== User Data Methods ====================

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _keyUserId, value: userId);
    } catch (e) {
      debugPrint('❌ Error saving user ID: $e');
    }
  }

  /// Get user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (e) {
      debugPrint('❌ Error reading user ID: $e');
      return null;
    }
  }

  /// Save user email
  Future<void> saveUserEmail(String email) async {
    try {
      await _storage.write(key: _keyUserEmail, value: email);
    } catch (e) {
      debugPrint('❌ Error saving user email: $e');
    }
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _keyUserEmail);
    } catch (e) {
      debugPrint('❌ Error reading user email: $e');
      return null;
    }
  }

  /// Save user phone
  Future<void> saveUserPhone(String phone) async {
    try {
      await _storage.write(key: _keyUserPhone, value: phone);
    } catch (e) {
      debugPrint('❌ Error saving user phone: $e');
    }
  }

  /// Get user phone
  Future<String?> getUserPhone() async {
    try {
      return await _storage.read(key: _keyUserPhone);
    } catch (e) {
      debugPrint('❌ Error reading user phone: $e');
      return null;
    }
  }

  /// Save user name
  Future<void> saveUserName(String name) async {
    try {
      await _storage.write(key: _keyUserName, value: name);
    } catch (e) {
      debugPrint('❌ Error saving user name: $e');
    }
  }

  /// Get user name
  Future<String?> getUserName() async {
    try {
      return await _storage.read(key: _keyUserName);
    } catch (e) {
      debugPrint('❌ Error reading user name: $e');
      return null;
    }
  }

  /// Save user profile picture
  Future<void> saveUserPic(String pic) async {
    try {
      await _storage.write(key: _keyUserPic, value: pic);
    } catch (e) {
      debugPrint('❌ Error saving user pic: $e');
    }
  }

  /// Get user profile picture
  Future<String?> getUserPic() async {
    try {
      return await _storage.read(key: _keyUserPic);
    } catch (e) {
      debugPrint('❌ Error reading user pic: $e');
      return null;
    }
  }

  /// Save user role ID
  Future<void> saveUserRoleId(int roleId) async {
    try {
      await _storage.write(key: _keyUserRoleId, value: roleId.toString());
    } catch (e) {
      debugPrint('❌ Error saving user role ID: $e');
    }
  }

  /// Get user role ID
  Future<int> getUserRoleId() async {
    try {
      final value = await _storage.read(key: _keyUserRoleId);
      return int.tryParse(value ?? '0') ?? 0;
    } catch (e) {
      debugPrint('❌ Error reading user role ID: $e');
      return 0;
    }
  }

  /// Save user password (encrypted)
  Future<void> saveUserPassword(String password) async {
    try {
      await _storage.write(key: _keyUserPassword, value: password);
      debugPrint('✅ User password saved securely');
    } catch (e) {
      debugPrint('❌ Error saving user password: $e');
    }
  }

  /// Get user password
  Future<String?> getUserPassword() async {
    try {
      return await _storage.read(key: _keyUserPassword);
    } catch (e) {
      debugPrint('❌ Error reading user password: $e');
      return null;
    }
  }

  /// Delete user password
  Future<void> deleteUserPassword() async {
    try {
      await _storage.delete(key: _keyUserPassword);
      debugPrint('🗑️ User password deleted');
    } catch (e) {
      debugPrint('❌ Error deleting user password: $e');
    }
  }

  /// Save access token (for API authentication)
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _keyAccessToken, value: token);
      debugPrint('✅ Access token saved securely');
    } catch (e) {
      debugPrint('❌ Error saving access token: $e');
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _keyAccessToken);
    } catch (e) {
      debugPrint('❌ Error reading access token: $e');
      return null;
    }
  }

  /// Delete access token
  Future<void> deleteAccessToken() async {
    try {
      await _storage.delete(key: _keyAccessToken);
      debugPrint('🗑️ Access token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting access token: $e');
    }
  }

  /// Save FCM token
  Future<void> saveFCMToken(String token) async {
    try {
      await _storage.write(key: _keyFCMToken, value: token);
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _storage.read(key: _keyFCMToken);
    } catch (e) {
      debugPrint('❌ Error reading FCM token: $e');
      return null;
    }
  }

  /// Save user logged in status
  Future<void> setUserLoggedIn(bool isLoggedIn) async {
    try {
      await _storage.write(
        key: _keyIsUserLoggedIn,
        value: isLoggedIn.toString(),
      );
    } catch (e) {
      debugPrint('❌ Error saving login status: $e');
    }
  }

  /// Get user logged in status
  Future<bool> isUserLoggedIn() async {
    try {
      final value = await _storage.read(key: _keyIsUserLoggedIn);
      return value == 'true';
    } catch (e) {
      debugPrint('❌ Error reading login status: $e');
      return false;
    }
  }

  /// Save complete user session (convenience method)
  Future<void> saveUserSession({
    required int userId,
    required String email,
    required String name,
    required String pic,
    String? accessToken,
    int? roleId,
  }) async {
    try {
      await saveUserId(userId.toString());
      await saveUserEmail(email);
      await saveUserName(name);
      await saveUserPic(pic);
      await setUserLoggedIn(true);

      if (accessToken != null) {
        await saveAccessToken(accessToken);
      }

      if (roleId != null) {
        await saveUserRoleId(roleId);
      }

      await saveLastLoginTime();
      debugPrint('✅ Complete user session saved securely');
    } catch (e) {
      debugPrint('❌ Error saving user session: $e');
      rethrow;
    }
  }

  /// Get complete user session (convenience method)
  Future<Map<String, dynamic>?> getUserSession() async {
    try {
      final userId = await getUserId();
      final email = await getUserEmail();
      final name = await getUserName();
      final pic = await getUserPic();
      final isLoggedIn = await isUserLoggedIn();
      final accessToken = await getAccessToken();

      if (userId == null || !isLoggedIn) {
        return null;
      }

      return {
        'userId': int.tryParse(userId),
        'email': email,
        'name': name,
        'pic': pic,
        'isLoggedIn': isLoggedIn,
        'accessToken': accessToken,
      };
    } catch (e) {
      debugPrint('❌ Error reading user session: $e');
      return null;
    }
  }

  // ==================== Settings Methods ====================

  /// Save biometric enabled status
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(
        key: _keyBiometricEnabled,
        value: enabled.toString(),
      );
    } catch (e) {
      debugPrint('❌ Error saving biometric status: $e');
    }
  }

  /// Get biometric enabled status
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _storage.read(key: _keyBiometricEnabled);
      return value == 'true';
    } catch (e) {
      debugPrint('❌ Error reading biometric status: $e');
      return false;
    }
  }

  /// Save last login time
  Future<void> saveLastLoginTime() async {
    try {
      await _storage.write(
        key: _keyLastLoginTime,
        value: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('❌ Error saving last login time: $e');
    }
  }

  /// Get last login time
  Future<DateTime?> getLastLoginTime() async {
    try {
      final value = await _storage.read(key: _keyLastLoginTime);
      return value != null ? DateTime.parse(value) : null;
    } catch (e) {
      debugPrint('❌ Error reading last login time: $e');
      return null;
    }
  }

  // ==================== Generic Methods ====================

  /// Save any key-value pair securely
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('❌ Error writing to secure storage: $e');
      rethrow;
    }
  }

  /// Read any value by key
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('❌ Error reading from secure storage: $e');
      return null;
    }
  }

  /// Delete specific key
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('❌ Error deleting from secure storage: $e');
    }
  }

  /// Clear all stored data (use on logout)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      debugPrint('🗑️ All secure data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing secure storage: $e');
    }
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      debugPrint('❌ Error checking key existence: $e');
      return false;
    }
  }

  /// Get all keys
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      debugPrint('❌ Error reading all data: $e');
      return {};
    }
  }

  // ==================== App Preferences Methods ====================

  /// Save onboarding completion status
  Future<void> setHasSeenOnboarding(bool hasSeen) async {
    try {
      await _storage.write(
        key: _keyHasSeenOnboarding,
        value: hasSeen.toString(),
      );
      debugPrint('✅ Onboarding status saved: $hasSeen');
    } catch (e) {
      debugPrint('❌ Error saving onboarding status: $e');
    }
  }

  /// Get onboarding completion status
  Future<bool> hasSeenOnboarding() async {
    try {
      final value = await _storage.read(key: _keyHasSeenOnboarding);
      return value == 'true';
    } catch (e) {
      debugPrint('❌ Error reading onboarding status: $e');
      return false;
    }
  }

  /// Save first install flag
  Future<void> setFirstInstall(bool isFirst) async {
    try {
      await _storage.write(
        key: _keyFirstInstall,
        value: isFirst.toString(),
      );
      debugPrint('✅ First install flag saved: $isFirst');
    } catch (e) {
      debugPrint('❌ Error saving first install flag: $e');
    }
  }

  /// Get first install flag
  Future<bool> isFirstInstall() async {
    try {
      final value = await _storage.read(key: _keyFirstInstall);
      // Default to true if not set (actual first install)
      if (value == null) return true;
      return value == 'true';
    } catch (e) {
      debugPrint('❌ Error reading first install flag: $e');
      return true; // Default to true on error
    }
  }

  /// Clear app preferences only (keep user data)
  Future<void> clearAppPreferences() async {
    try {
      await _storage.delete(key: _keyHasSeenOnboarding);
      await _storage.delete(key: _keyFirstInstall);
      debugPrint('🗑️ App preferences cleared');
    } catch (e) {
      debugPrint('❌ Error clearing app preferences: $e');
    }
  }
}