import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../utils/app_logger.dart';
import 'env_config_service.dart';
import 'session_manager.dart';

/// AccountStatusService - Manages account deactivation state across devices
/// This service listens for real-time account status changes and handles
/// automatic logout when account is deactivated from any device.
class AccountStatusService extends GetxService {
  static AccountStatusService get instance => Get.find<AccountStatusService>();

  // Observable states
  final RxBool isAccountDeactivated = false.obs;
  final RxBool isCheckingStatus = false.obs;
  final Rx<String?> deactivationReason = Rx<String?>(null);

  // Firebase listener
  StreamSubscription<DocumentSnapshot>? _statusListener;
  String? _currentUserId;

  // Debounce timer to prevent multiple rapid checks
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    AppLogger.lifecycle('[AccountStatusService] Initialized');
  }

  @override
  void onClose() {
    _cancelStatusListener();
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Start listening to account status changes for a user
  Future<void> startListening(String userId) async {
    if (userId.isEmpty || userId == '0') {
      AppLogger.error('[AccountStatusService] Invalid userId: $userId');
      return;
    }

    // Cancel existing listener if any
    await _cancelStatusListener();

    _currentUserId = userId;
    AppLogger.lifecycle('[AccountStatusService] Starting status listener for user: $userId');

    try {
      _statusListener = FirebaseFirestore.instance
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(userId)
          .snapshots()
          .listen(
        (snapshot) => _handleStatusChange(snapshot),
        onError: (error) {
          AppLogger.error('[AccountStatusService] Listener error: $error');
        },
      );

      AppLogger.success('[AccountStatusService] Status listener started');
    } catch (e) {
      AppLogger.error('[AccountStatusService] Failed to start listener: $e');
    }
  }

  /// Handle status change from Firebase
  void _handleStatusChange(DocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      AppLogger.error('[AccountStatusService] User document does not exist');
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>?;
    if (data == null) return;

    final bool isDeactivated = data['is_deactivated'] == true;
    final bool accountDeleted = data['account_deleted'] == true;

    AppLogger.lifecycle('[AccountStatusService] Status check - isDeactivated: $isDeactivated, accountDeleted: $accountDeleted');

    if (isDeactivated || accountDeleted) {
      // Debounce to prevent multiple rapid triggers
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _handleAccountDeactivated(
          reason: accountDeleted 
              ? 'Your account has been deleted.' 
              : 'Your account has been deactivated.',
        );
      });
    }
  }

  /// Handle account deactivation - clear session and redirect
  Future<void> _handleAccountDeactivated({String? reason}) async {
    if (isAccountDeactivated.value) {
      AppLogger.lifecycle('[AccountStatusService] Already handling deactivation, skipping...');
      return;
    }

    isAccountDeactivated.value = true;
    deactivationReason.value = reason;

    AppLogger.lifecycle('[AccountStatusService] 🚨 Account deactivated! Initiating cross-device logout...');

    // Cancel the listener first
    await _cancelStatusListener();

    // Clear all session data using SessionManager
    await SessionManager.instance.clearAllSessionData();

    // Navigate to deactivation screen
    _navigateToDeactivationScreen(reason);
  }

  /// Navigate to deactivation screen
  void _navigateToDeactivationScreen(String? reason) {
    // Check if we're already on the deactivation screen
    if (Get.currentRoute == AppRoutes.ACCOUNT_DEACTIVATED) {
      return;
    }

    AppLogger.lifecycle('[AccountStatusService] Navigating to deactivation screen...');

    Get.offAllNamed(
      AppRoutes.ACCOUNT_DEACTIVATED,
      arguments: {'reason': reason ?? 'Your account has been deactivated.'},
    );
  }

  /// Check account status via API (for on-demand validation)
  Future<bool> validateAccountStatus() async {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      return true; // No user to validate
    }

    isCheckingStatus.value = true;

    try {
      final doc = await FirebaseFirestore.instance
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(_currentUserId)
          .get();

      if (!doc.exists) {
        await _handleAccountDeactivated(reason: 'Your account no longer exists.');
        return false;
      }

      final data = doc.data();
      if (data == null) return true;

      final bool isDeactivated = data['is_deactivated'] == true;
      final bool accountDeleted = data['account_deleted'] == true;

      if (isDeactivated || accountDeleted) {
        await _handleAccountDeactivated(
          reason: accountDeleted 
              ? 'Your account has been deleted.' 
              : 'Your account has been deactivated.',
        );
        return false;
      }

      return true;
    } catch (e) {
      AppLogger.error('[AccountStatusService] Error validating status: $e');
      return true; // Assume valid on error to prevent false logouts
    } finally {
      isCheckingStatus.value = false;
    }
  }

  /// Handle API response indicating account is deactivated
  Future<void> handleDeactivatedApiResponse() async {
    AppLogger.lifecycle('[AccountStatusService] API returned account_Deactivated');
    await _handleAccountDeactivated(
      reason: 'Your account has been deactivated. Contact support for assistance.',
    );
  }

  /// Cancel the status listener
  Future<void> _cancelStatusListener() async {
    await _statusListener?.cancel();
    _statusListener = null;
    AppLogger.lifecycle('[AccountStatusService] Status listener cancelled');
  }

  /// Stop listening and reset state
  Future<void> stopListening() async {
    await _cancelStatusListener();
    _currentUserId = null;
    isAccountDeactivated.value = false;
    deactivationReason.value = null;
    AppLogger.lifecycle('[AccountStatusService] Stopped listening and reset state');
  }

  /// Reset the deactivation state (used after showing deactivation screen)
  void resetDeactivationState() {
    isAccountDeactivated.value = false;
    deactivationReason.value = null;
  }
}
