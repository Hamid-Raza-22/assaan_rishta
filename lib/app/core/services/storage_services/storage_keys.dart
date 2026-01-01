/// Storage Keys for SharedPreferences
///
/// IMPORTANT: Sensitive data has been migrated to SecureStorageService
///
/// MIGRATED TO SECURE STORAGE:
/// - token -> Use SecureStorageService.saveAccessToken()
/// - userId -> Use SecureStorageService.saveUserId()
/// - userName -> Use SecureStorageService.saveUserName()
/// - userEmail -> Use SecureStorageService.saveUserEmail()
/// - userPic -> Use SecureStorageService.saveUserPic()
/// - userPassword -> Use SecureStorageService.saveUserPassword()
/// - isUserLoggedIn -> Use SecureStorageService.setUserLoggedIn()
///
/// These keys are kept for backward compatibility only.
/// Use SecureStorageService for all sensitive data going forward.
class StorageKeys {
  static const String token = "token";
  static const String userId = "userId";
  static const String userName = "userName";
  static const String userEmail = "userEmail";
  static const String userPic = "userPic";
  static const String userPassword = "userPassword";
  static const String isUserLoggedIn = "isUserLoggedIn";
  static const String userRoleId = "userRoleId";
}