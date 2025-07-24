// chat_list_viewmodel.dart - Enhanced for notification handling

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/export.dart';
import '../domain/export.dart';

class ChatListController extends GetxController {
  final useCase = Get.find<UserManagementUseCase>();

  // Reactive variables
  final RxList<ChatUser> chatUsers = <ChatUser>[].obs;
  final RxList<ChatUser> searchResults = <ChatUser>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs; // ADDED

  // Streams
  StreamSubscription? _myUsersSubscription;
  StreamSubscription? _allUsersSubscription;

  // ADDED: Track last refresh time
  DateTime? _lastRefreshTime;

  String get currentUserId => useCase.getUserId().toString();

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 ChatListController initialized for INSTANT sorting');
    _initializeStreams();
  }

  void _initializeStreams() {
    debugPrint('🔄 Setting up REAL-TIME streams...');

    // Cancel existing subscriptions
    _myUsersSubscription?.cancel();
    _allUsersSubscription?.cancel();

    // ENHANCED: Direct stream with built-in sorting from Firebase
    _myUsersSubscription = FirebaseFirestore.instance
        .collection('Hamid_users')
        .doc(currentUserId)
        .collection('my_users')
        .orderBy('last_message_time', descending: true) // INSTANT SORTING
        .snapshots()
        .listen((myUsersSnapshot) {

      debugPrint('📥 My users stream triggered with ${myUsersSnapshot.docs.length} users');

      final userIds = myUsersSnapshot.docs.map((e) => e.id).toList();

      if (userIds.isEmpty) {
        chatUsers.clear();
        isLoading.value = false;
        isRefreshing.value = false; // ADDED
        debugPrint('📋 No chat users found');
        return;
      }

      // Get user details with preserved order from Firebase sorting
      _allUsersSubscription?.cancel();
      _allUsersSubscription = FirebaseFirestore.instance
          .collection('Hamid_users')
          .where('id', whereIn: userIds)
          .snapshots()
          .listen((allUsersSnapshot) {

        debugPrint('👥 All users stream triggered with ${allUsersSnapshot.docs.length} users');

        // Create a map for quick lookup
        final userMap = <String, ChatUser>{};
        for (var doc in allUsersSnapshot.docs) {
          final user = ChatUser.fromJson(doc.data());
          userMap[user.id] = user;
        }

        // INSTANT SORTING: Preserve the order from my_users collection
        final sortedUsers = <ChatUser>[];
        for (var myUserDoc in myUsersSnapshot.docs) {
          final userId = myUserDoc.id;
          if (userMap.containsKey(userId)) {
            sortedUsers.add(userMap[userId]!);
          }
        }

        // INSTANT UPDATE - No delays or debouncing
        chatUsers.value = sortedUsers;
        isLoading.value = false;
        isRefreshing.value = false; // ADDED
        _lastRefreshTime = DateTime.now(); // ADDED

        debugPrint('✅ INSTANT chat list updated with ${sortedUsers.length} users');
        debugPrint('📋 Order: ${sortedUsers.map((u) => u.name).join(', ')}');
      }, onError: (error) {
        debugPrint('❌ Error in all users stream: $error');
        isLoading.value = false;
        isRefreshing.value = false;
      });
    }, onError: (error) {
      debugPrint('❌ Error in my users stream: $error');
      isLoading.value = false;
      isRefreshing.value = false;
    });
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    final lowerQuery = query.toLowerCase();
    searchResults.value = chatUsers.where((user) {
      return user.name.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchResults.clear();
    }
  }

  String getConversationId(String userId1, String userId2) {
    return userId1.compareTo(userId2) <= 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  Future<void> deleteChat(ChatUser user) async {
    try {
      debugPrint('🗑️ Deleting chat with ${user.name}...');

      // Create batch for atomic operation
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Remove from my list
      batch.delete(
        FirebaseFirestore.instance
            .collection('Hamid_users')
            .doc(currentUserId)
            .collection('my_users')
            .doc(user.id),
      );

      // Remove from their list
      batch.delete(
        FirebaseFirestore.instance
            .collection('Hamid_users')
            .doc(user.id)
            .collection('my_users')
            .doc(currentUserId),
      );

      // Execute batch
      await batch.commit();

      // Delete messages (separate operation)
      final chatId = getConversationId(currentUserId, user.id);
      final messages = await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .doc(chatId)
          .collection('messages')
          .get();

      // Delete messages in batches
      if (messages.docs.isNotEmpty) {
        final deleteBatch = FirebaseFirestore.instance.batch();
        for (var doc in messages.docs) {
          deleteBatch.delete(doc.reference);
        }
        await deleteBatch.commit();
      }

      Get.snackbar(
        'Success',
        'Chat with ${user.name} deleted',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      debugPrint('✅ Chat deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting chat: $e');
      Get.snackbar(
        'Error',
        'Failed to delete chat',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // ENHANCED: Force refresh with debouncing
  void forceRefresh() {
    debugPrint('🔄 Force refreshing chat list...');

    // Prevent multiple rapid refreshes
    if (isRefreshing.value) {
      debugPrint('⏳ Already refreshing, skipping...');
      return;
    }

    // Check if last refresh was too recent (less than 1 second ago)
    if (_lastRefreshTime != null) {
      final timeSinceLastRefresh = DateTime.now().difference(_lastRefreshTime!);
      if (timeSinceLastRefresh.inMilliseconds < 1000) {
        debugPrint('⏱️ Last refresh too recent, skipping...');
        return;
      }
    }

    isRefreshing.value = true;
    isLoading.value = true;

    // Re-initialize streams for fresh data
    _initializeStreams();

    debugPrint('✅ Force refresh initiated');
  }

  // ADDED: Refresh with user feedback
  Future<void> refreshWithFeedback() async {
    debugPrint('🔄 Manual refresh with user feedback...');

    try {
      isRefreshing.value = true;

      // Small delay to show loading state
      await Future.delayed(const Duration(milliseconds: 100));

      // Re-initialize streams
      _initializeStreams();

      // Wait for streams to settle
      await Future.delayed(const Duration(milliseconds: 500));

      Get.snackbar(
        'Refreshed',
        'Chat list updated',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
      );

      debugPrint('✅ Manual refresh completed');
    } catch (e) {
      debugPrint('❌ Error in manual refresh: $e');
      Get.snackbar(
        'Error',
        'Failed to refresh',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  // ADDED: Method to manually update user position
  void moveUserToTop(String userId) {
    debugPrint('⬆️ Moving user $userId to top...');

    final userIndex = chatUsers.indexWhere((user) => user.id == userId);
    if (userIndex > 0) {
      final user = chatUsers.removeAt(userIndex);
      chatUsers.insert(0, user);
      debugPrint('✅ User moved to top in local list');
    }
  }

  // ENHANCED: Method to check if a user should be at top
  bool shouldMoveToTop(String userId) {
    if (chatUsers.isEmpty) return false;
    return chatUsers.first.id != userId;
  }

  // ADDED: Method to get user position
  int getUserPosition(String userId) {
    return chatUsers.indexWhere((user) => user.id == userId);
  }

  // ADDED: Method to check if list is fresh
  bool get isListFresh {
    if (_lastRefreshTime == null) return false;
    final timeSinceRefresh = DateTime.now().difference(_lastRefreshTime!);
    return timeSinceRefresh.inSeconds < 30; // Fresh if refreshed within 30 seconds
  }

  // ADDED: Get refresh status
  String get refreshStatus {
    if (isRefreshing.value) return 'Refreshing...';
    if (isLoading.value) return 'Loading...';
    if (_lastRefreshTime == null) return 'Not refreshed';

    final timeSinceRefresh = DateTime.now().difference(_lastRefreshTime!);
    if (timeSinceRefresh.inMinutes < 1) {
      return 'Updated ${timeSinceRefresh.inSeconds}s ago';
    } else {
      return 'Updated ${timeSinceRefresh.inMinutes}m ago';
    }
  }

  @override
  void onClose() {
    debugPrint('🔚 ChatListController closing...');
    _myUsersSubscription?.cancel();
    _allUsersSubscription?.cancel();
    super.onClose();
  }
}