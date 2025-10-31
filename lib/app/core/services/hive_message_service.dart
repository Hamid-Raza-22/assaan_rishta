// Hive Message Storage Service
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/models/chat_model/message.dart';

class HiveMessageService {
  static const String _messagesBoxPrefix = 'messages_';
  static const String _deletionBoxName = 'chat_deletions';
  
  // Singleton pattern
  static final HiveMessageService _instance = HiveMessageService._internal();
  factory HiveMessageService() => _instance;
  HiveMessageService._internal();

  // Get box name for specific user chat
  String _getBoxName(String userId) => '$_messagesBoxPrefix$userId';

  // Initialize boxes - call this after Hive.init
  Future<void> ensureBoxOpen(String userId) async {
    try {
      final boxName = _getBoxName(userId);
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<Message>(boxName);
        debugPrint('📦 Opened Hive box: $boxName');
      }
    } catch (e) {
      debugPrint('❌ Error opening box for user $userId: $e');
    }
  }

  // PERFORMANCE: Save messages incrementally (only new/updated messages)
  Future<void> saveMessages(String userId, List<Message> messages) async {
    try {
      await ensureBoxOpen(userId);
      final box = Hive.box<Message>(_getBoxName(userId));
      
      // FIXED: Don't clear! Use incremental updates instead
      // This prevents re-saving all messages every time
      int newCount = 0;
      int updatedCount = 0;
      
      for (var message in messages) {
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
  Future<List<Message>> getMessages(String userId) async {
    try {
      await ensureBoxOpen(userId);
      final box = Hive.box<Message>(_getBoxName(userId));
      
      final messages = box.values.toList();
      
      // Sort by timestamp (sent field)
      messages.sort((a, b) {
        try {
          final aTime = int.parse(a.sent);
          final bTime = int.parse(b.sent);
          return aTime.compareTo(bTime);
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
  Future<void> addMessage(String userId, Message message) async {
    try {
      await ensureBoxOpen(userId);
      final box = Hive.box<Message>(_getBoxName(userId));
      await box.put(message.sent, message);
      debugPrint('💾 Added message to Hive for user: $userId');
    } catch (e) {
      debugPrint('❌ Error adding message for user $userId: $e');
    }
  }

  // Update a single message (for status updates)
  Future<void> updateMessage(String userId, Message message) async {
    try {
      await ensureBoxOpen(userId);
      final box = Hive.box<Message>(_getBoxName(userId));
      
      if (box.containsKey(message.sent)) {
        await box.put(message.sent, message);
        debugPrint('🔄 Updated message in Hive for user: $userId');
      }
    } catch (e) {
      debugPrint('❌ Error updating message for user $userId: $e');
    }
  }

  // Delete a single message
  Future<void> deleteMessage(String userId, String messageId) async {
    try {
      await ensureBoxOpen(userId);
      final box = Hive.box<Message>(_getBoxName(userId));
      await box.delete(messageId);
      debugPrint('🗑️ Deleted message from Hive for user: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting message for user $userId: $e');
    }
  }

  // Clear all messages for a specific user
  Future<void> clearMessages(String userId) async {
    try {
      await ensureBoxOpen(userId);
      final box = Hive.box<Message>(_getBoxName(userId));
      await box.clear();
      debugPrint('🧹 Cleared all messages from Hive for user: $userId');
    } catch (e) {
      debugPrint('❌ Error clearing messages for user $userId: $e');
    }
  }

  // Save deletion timestamp for a chat
  Future<void> saveDeletionTime(String userId, String timestamp) async {
    try {
      if (!Hive.isBoxOpen(_deletionBoxName)) {
        await Hive.openBox(_deletionBoxName);
      }
      final box = Hive.box(_deletionBoxName);
      await box.put(userId, timestamp);
      debugPrint('💾 Saved deletion time for user: $userId');
    } catch (e) {
      debugPrint('❌ Error saving deletion time: $e');
    }
  }

  // Get deletion timestamp for a chat
  Future<String?> getDeletionTime(String userId) async {
    try {
      if (!Hive.isBoxOpen(_deletionBoxName)) {
        await Hive.openBox(_deletionBoxName);
      }
      final box = Hive.box(_deletionBoxName);
      return box.get(userId) as String?;
    } catch (e) {
      debugPrint('❌ Error getting deletion time: $e');
      return null;
    }
  }

  // Clear deletion timestamp for a chat
  Future<void> clearDeletionTime(String userId) async {
    try {
      if (!Hive.isBoxOpen(_deletionBoxName)) {
        await Hive.openBox(_deletionBoxName);
      }
      final box = Hive.box(_deletionBoxName);
      await box.delete(userId);
      debugPrint('🧹 Cleared deletion time for user: $userId');
    } catch (e) {
      debugPrint('❌ Error clearing deletion time: $e');
    }
  }

  // Close box for a specific user (optional, for memory management)
  Future<void> closeBox(String userId) async {
    try {
      final boxName = _getBoxName(userId);
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
  Future<int> getMessageCount(String userId) async {
    try {
      await ensureBoxOpen(userId);
      final box = Hive.box<Message>(_getBoxName(userId));
      return box.length;
    } catch (e) {
      debugPrint('❌ Error getting message count: $e');
      return 0;
    }
  }

  // Check if messages exist for a user
  Future<bool> hasMessages(String userId) async {
    try {
      final count = await getMessageCount(userId);
      return count > 0;
    } catch (e) {
      return false;
    }
  }
}
