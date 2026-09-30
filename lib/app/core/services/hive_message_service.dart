// Hive Message Storage Service
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/models/chat_model/message.dart';

class HiveMessageService {
  static const String _messagesBoxPrefix = 'messages_';
  
  // Singleton pattern
  static final HiveMessageService _instance = HiveMessageService._internal();
  factory HiveMessageService() => _instance;
  HiveMessageService._internal();

  // Get box name for specific user chat
  String _getBoxName(String ownerId, String userId) =>
      '${_messagesBoxPrefix}${ownerId}_$userId';
  String _deletionBoxName(String ownerId) => 'chat_deletions_$ownerId';

  bool _belongsToChat(Message message, String ownerId, String userId) =>
      (message.fromId == ownerId && message.toId == userId) ||
      (message.fromId == userId && message.toId == ownerId);

  // Initialize boxes - call this after Hive.init
  Future<void> ensureBoxOpen(String ownerId, String userId) async {
    try {
      final boxName = _getBoxName(ownerId, userId);
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<Message>(boxName);
        debugPrint('📦 Opened Hive box: $boxName');
      }
    } catch (e) {
      debugPrint('❌ Error opening box for user $userId: $e');
    }
  }

  // PERFORMANCE: Save messages incrementally (only new/updated messages)
  Future<void> saveMessages(String ownerId, String userId, List<Message> messages) async {
    try {
      await ensureBoxOpen(ownerId, userId);
      final box = Hive.box<Message>(_getBoxName(ownerId, userId));
      
      // FIXED: Don't clear! Use incremental updates instead
      // This prevents re-saving all messages every time
      int newCount = 0;
      int updatedCount = 0;
      
      for (var message in messages) {
        if (!_belongsToChat(message, ownerId, userId)) continue;
        final existingMessage = box.get(message.sent);
        
        if (existingMessage == null) {
          // New message - save it
          await box.put(message.sent, message);
          newCount++;
        } else if (_hasMessageChanged(existingMessage, message)) {
          // Existing message but status changed - update it
          await box.put(message.sent, message);
          updatedCount++;
        }
        // Else: Message unchanged, skip save
      }
      
      if (newCount > 0 || updatedCount > 0) {
        debugPrint('💾 Hive: $newCount new, $updatedCount updated for user $userId');
      }
    } catch (e) {
      debugPrint('❌ Error saving messages for user $userId: $e');
    }
  }
  
  // Check if message status/content changed
  bool _hasMessageChanged(Message old, Message newMsg) {
    return old.status != newMsg.status ||
           old.read != newMsg.read ||
           old.delivered != newMsg.delivered ||
           old.msg != newMsg.msg;
  }

  // Get messages for a specific user
  Future<List<Message>> getMessages(String ownerId, String userId) async {
    try {
      await ensureBoxOpen(ownerId, userId);
      final box = Hive.box<Message>(_getBoxName(ownerId, userId));
      
      final messages = box.values
          .where((message) => _belongsToChat(message, ownerId, userId))
          .toList();

      // Older versions used partner-only (and sometimes empty) box names.
      // Copy only messages whose two participants match this conversation.
      if (messages.isEmpty) {
        for (final legacyName in ['$_messagesBoxPrefix$userId', _messagesBoxPrefix]) {
          if (!Hive.isBoxOpen(legacyName)) {
            if (!await Hive.boxExists(legacyName)) continue;
            await Hive.openBox<Message>(legacyName);
          }
          final legacy = Hive.box<Message>(legacyName);
          for (final message in legacy.values) {
            if (_belongsToChat(message, ownerId, userId) &&
                !box.containsKey(message.sent)) {
              messages.add(message);
              await box.put(message.sent, message);
            }
          }
        }
      }
      
      // Reverse ListView expects the newest message at index zero.
      messages.sort((a, b) {
        try {
          final aTime = int.parse(a.sent);
          final bTime = int.parse(b.sent);
          return bTime.compareTo(aTime);
        } catch (e) {
          return 0;
        }
      });
      
      debugPrint('📨 Retrieved ${messages.length} messages from Hive for user: $userId');
      return messages;
    } catch (e) {
      debugPrint('❌ Error getting messages for user $userId: $e');
      return [];
    }
  }

  // Add a single message
  Future<void> addMessage(String ownerId, String userId, Message message) async {
    try {
      if (!_belongsToChat(message, ownerId, userId)) return;
      await ensureBoxOpen(ownerId, userId);
      final box = Hive.box<Message>(_getBoxName(ownerId, userId));
      await box.put(message.sent, message);
      debugPrint('💾 Added message to Hive for user: $userId');
    } catch (e) {
      debugPrint('❌ Error adding message for user $userId: $e');
    }
  }

  // Update a single message (for status updates)
  Future<void> updateMessage(String ownerId, String userId, Message message) async {
    try {
      if (!_belongsToChat(message, ownerId, userId)) return;
      await ensureBoxOpen(ownerId, userId);
      final box = Hive.box<Message>(_getBoxName(ownerId, userId));
      
      if (box.containsKey(message.sent)) {
        await box.put(message.sent, message);
        debugPrint('🔄 Updated message in Hive for user: $userId');
      }
    } catch (e) {
      debugPrint('❌ Error updating message for user $userId: $e');
    }
  }

  // Delete a single message
  Future<void> deleteMessage(String ownerId, String userId, String messageId) async {
    try {
      await ensureBoxOpen(ownerId, userId);
      final box = Hive.box<Message>(_getBoxName(ownerId, userId));
      await box.delete(messageId);
      debugPrint('🗑️ Deleted message from Hive for user: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting message for user $userId: $e');
    }
  }

  // Clear all messages for a specific user
  Future<void> clearMessages(String ownerId, String userId) async {
    try {
      await ensureBoxOpen(ownerId, userId);
      final box = Hive.box<Message>(_getBoxName(ownerId, userId));
      await box.clear();
      debugPrint('🧹 Cleared all messages from Hive for user: $userId');
    } catch (e) {
      debugPrint('❌ Error clearing messages for user $userId: $e');
    }
  }

  // Save deletion timestamp for a chat
  Future<void> saveDeletionTime(String ownerId, String userId, String timestamp) async {
    try {
      final boxName = _deletionBoxName(ownerId);
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
      }
      final box = Hive.box(boxName);
      await box.put(userId, timestamp);
      debugPrint('💾 Saved deletion time for user: $userId');
    } catch (e) {
      debugPrint('❌ Error saving deletion time: $e');
    }
  }

  // Get deletion timestamp for a chat
  Future<String?> getDeletionTime(String ownerId, String userId) async {
    try {
      final boxName = _deletionBoxName(ownerId);
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
      }
      final box = Hive.box(boxName);
      return box.get(userId) as String?;
    } catch (e) {
      debugPrint('❌ Error getting deletion time: $e');
      return null;
    }
  }

  // Clear deletion timestamp for a chat
  Future<void> clearDeletionTime(String ownerId, String userId) async {
    try {
      final boxName = _deletionBoxName(ownerId);
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
      }
      final box = Hive.box(boxName);
      await box.delete(userId);
      debugPrint('🧹 Cleared deletion time for user: $userId');
    } catch (e) {
      debugPrint('❌ Error clearing deletion time: $e');
    }
  }

  // Close box for a specific user (optional, for memory management)
  Future<void> closeBox(String ownerId, String userId) async {
    try {
      final boxName = _getBoxName(ownerId, userId);
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box<Message>(boxName).close();
        debugPrint('📪 Closed Hive box: $boxName');
      }
    } catch (e) {
      debugPrint('❌ Error closing box for user $userId: $e');
    }
  }

  // Close all boxes (call on app shutdown if needed)
  Future<void> closeAllBoxes() async {
    try {
      await Hive.close();
      debugPrint('📪 Closed all Hive boxes');
    } catch (e) {
      debugPrint('❌ Error closing all boxes: $e');
    }
  }

  // Get count of messages for a user
  Future<int> getMessageCount(String ownerId, String userId) async {
    try {
      await ensureBoxOpen(ownerId, userId);
      final box = Hive.box<Message>(_getBoxName(ownerId, userId));
      return box.length;
    } catch (e) {
      debugPrint('❌ Error getting message count: $e');
      return 0;
    }
  }

  // Check if messages exist for a user
  Future<bool> hasMessages(String ownerId, String userId) async {
    try {
      final count = await getMessageCount(ownerId, userId);
      return count > 0;
    } catch (e) {
      return false;
    }
  }
}
