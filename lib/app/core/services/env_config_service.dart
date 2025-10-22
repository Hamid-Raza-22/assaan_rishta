import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment Configuration Service
/// Provides centralized access to all environment variables from .env file
class EnvConfig {
  // Private constructor to prevent instantiation
  EnvConfig._();

  /// Initialize environment variables
  /// Must be called before accessing any environment variables
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  // API Configuration
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get authBaseUrl => dotenv.env['AUTH_BASE_URL'] ?? '';

  // Firebase Configuration
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String get firebaseMessagingSenderId => 
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket => 
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';

  // PayFast Configuration
  static String get payfastCheckoutUrl => 
      dotenv.env['PAYFAST_CHECKOUT_URL'] ?? '';
  static String get payfastTransactionUrl => 
      dotenv.env['PAYFAST_TRANSACTION_URL'] ?? '';
  static String get payfastSuccessUrl => dotenv.env['PAYFAST_SUCCESS_URL'] ?? '';
  static String get payfastFailureUrl => dotenv.env['PAYFAST_FAILURE_URL'] ?? '';
  static String get payfastMerchantId => dotenv.env['PAYFAST_MERCHANT_ID'] ?? '';

  // App Constants
  static String get defaultProfileImage => 
      dotenv.env['DEFAULT_PROFILE_IMAGE'] ?? '';

  // Firebase Service Account (for Cloud Messaging)
  static String get firebaseServiceAccountType => 
      dotenv.env['FIREBASE_SERVICE_ACCOUNT_TYPE'] ?? 'service_account';
  static String get firebaseServiceAccountProjectId => 
      dotenv.env['FIREBASE_SERVICE_ACCOUNT_PROJECT_ID'] ?? '';
  static String get firebaseServiceAccountPrivateKeyId => 
      dotenv.env['FIREBASE_SERVICE_ACCOUNT_PRIVATE_KEY_ID'] ?? '';
  static String get firebaseServiceAccountPrivateKey {
    final key = dotenv.env['FIREBASE_SERVICE_ACCOUNT_PRIVATE_KEY'] ?? '';
    // Replace literal \n with actual newlines for PEM format
    return key.replaceAll('\\n', '\n');
  }
  static String get firebaseServiceAccountClientEmail => 
      dotenv.env['FIREBASE_SERVICE_ACCOUNT_CLIENT_EMAIL'] ?? '';
  static String get firebaseServiceAccountClientId => 
      dotenv.env['FIREBASE_SERVICE_ACCOUNT_CLIENT_ID'] ?? '';
  static String get firebaseServiceAccountAuthUri => 
      dotenv.env['FIREBASE_SERVICE_ACCOUNT_AUTH_URI'] ?? 'https://accounts.google.com/o/oauth2/auth';
  static String get firebaseServiceAccountTokenUri => 
      dotenv.env['FIREBASE_SERVICE_ACCOUNT_TOKEN_URI'] ?? 'https://oauth2.googleapis.com/token';
  static String get firebaseServiceAccountAuthProviderCertUrl => 
      dotenv.env['FIREBASE_SERVICE_ACCOUNT_AUTH_PROVIDER_CERT_URL'] ?? 'https://www.googleapis.com/oauth2/v1/certs';
  static String get firebaseServiceAccountClientCertUrl => 
      dotenv.env['FIREBASE_SERVICE_ACCOUNT_CLIENT_CERT_URL'] ?? '';
  static String get firebaseServiceAccountUniverseDomain => 
      dotenv.env['FIREBASE_SERVICE_ACCOUNT_UNIVERSE_DOMAIN'] ?? 'googleapis.com';

  /// Get Firebase Service Account JSON for googleapis_auth
  static Map<String, String> getFirebaseServiceAccountJson() {
    return {
      "type": firebaseServiceAccountType,
      "project_id": firebaseServiceAccountProjectId,
      "private_key_id": firebaseServiceAccountPrivateKeyId,
      "private_key": firebaseServiceAccountPrivateKey,
      "client_email": firebaseServiceAccountClientEmail,
      "client_id": firebaseServiceAccountClientId,
      "auth_uri": firebaseServiceAccountAuthUri,
      "token_uri": firebaseServiceAccountTokenUri,
      "auth_provider_x509_cert_url": firebaseServiceAccountAuthProviderCertUrl,
      "client_x509_cert_url": firebaseServiceAccountClientCertUrl,
      "universe_domain": firebaseServiceAccountUniverseDomain,
    };
  }

  /// Validate that all required environment variables are loaded
  static bool validate() {
    final required = [
      baseUrl,
      authBaseUrl,
      firebaseApiKey,
      firebaseAppId,
      firebaseProjectId,
    ];

    return required.every((value) => value.isNotEmpty);
  }

  /// Get environment variable by key (for any custom variables)
  static String? get(String key) => dotenv.env[key];
}
