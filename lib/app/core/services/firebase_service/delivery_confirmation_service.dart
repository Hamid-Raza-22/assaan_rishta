// Fixed delivery_confirmation_service.dart


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../env_config_service.dart';

class DeliveryConfirmationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fixed cloud function call - ensure all parameters are sent as strings
  static final Dio _dio = Dio();

  static Future<bool> confirmDeliveryViaDio({
    required String senderId,
    required String receiverId,
    required String messageTimestamp,
  }) async {
    try {
      final url = 'https://confirmmessagedelivery-7phof3qtoq-uc.a.run.app';

      final data = {
        "senderId": senderId,
        "receiverId": receiverId,
        "messageTimestamp": messageTimestamp,
      };

      debugPrint('☁️ Sending to Cloud Run via Dio...');
      debugPrint('📤 Request body: $data');

      final response = await _dio.post(
        url,
        data: {
          "data": {
            "senderId": senderId,
            "receiverId": receiverId,
            "messageTimestamp": messageTimestamp,
          }
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );


      debugPrint('☁️ Cloud Run response: ${response.data}');

      if (response.statusCode == 200) {
        return response.data['success'] == true;
      } else {
        debugPrint('❌ Unexpected status code: ${response.statusCode}');
        return false;
      }
    } catch (e, stack) {
      debugPrint('❌ Dio request failed: $e');
      debugPrint('   Stack: $stack');
      return false;
    }
  }
  // static Future<bool> confirmDeliveryViaCloudFunction({
  //   required String senderId,
  //   required String receiverId,
  //   required String messageTimestamp,
  // }) async {
  //   try {
  //     // Validate inputs
  //     if (senderId.isEmpty || receiverId.isEmpty || messageTimestamp.isEmpty) {
  //       debugPrint('⚠️ Invalid parameters for cloud function');
  //       return false;
  //     }
  //
  //     debugPrint('☁️ Preparing to call cloud function...');
  //     debugPrint('  senderId: "$senderId" (length: ${senderId.length})');
  //     debugPrint('  receiverId: "$receiverId" (length: ${receiverId.length})');
  //     debugPrint('  messageTimestamp: "$messageTimestamp" (length: ${messageTimestamp.length})');
  //
  //     final HttpsCallable callable = _functions.httpsCallable(
  //       'confirmMessageDelivery',
  //       options: HttpsCallableOptions(
  //         timeout: const Duration(seconds: 20),
  //       ),
  //     );
  //
  //     // FIX: Use a different approach - send as dynamic with explicit conversion
  //     final Map<String, dynamic> parameters = {
  //       'data': {
  //         'senderId': senderId,
  //         'receiverId': receiverId,
  //         'messageTimestamp': messageTimestamp,
  //       }
  //     };
  //
  //
  //     debugPrint('📤 Sending parameters: $parameters');
  //
  //     // Call the function with dynamic map
  //     final HttpsCallableResult result = await callable.call(parameters);
  //
  //     debugPrint('☁️ Cloud function response: ${result.data}');
  //
  //     return result.data?['success'] == true;
  //   } on FirebaseFunctionsException catch (e) {
  //     debugPrint('❌ Cloud function error: ${e.code} - ${e.message}');
  //     debugPrint('   Details: ${e.details}');
  //     debugPrint('   Plugin: ${e.plugin}');
  //     debugPrint('   Stack: ${e.stackTrace}');
  //     return false;
  //   } catch (e, stack) {
  //     debugPrint('❌ Unexpected error calling cloud function: $e');
  //     debugPrint('   Stack: $stack');
  //     return false;
  //   }
  // }

  // Simplified direct Firestore update without complex queries
  static Future<bool> confirmDeliveryDirectly({
    required String senderId,
    required String receiverId,
    required String messageTimestamp,
  }) async {
    try {
      // Generate both possible conversation IDs
      final String conversationId1 = _getConversationId(senderId, receiverId);
      final String conversationId2 = _getConversationId(receiverId, senderId);

      final deliveredTime = DateTime.now().millisecondsSinceEpoch.toString();

      debugPrint('🔍 Checking conversation: $conversationId1');

      // Try first conversation ID
      bool success = await _updateMessageDelivery(
        conversationId: conversationId1,
        messageTimestamp: messageTimestamp,
        deliveredTime: deliveredTime,
      );

      // If not found, try alternative conversation ID
      if (!success) {
        debugPrint('🔍 Checking alternative conversation: $conversationId2');
        success = await _updateMessageDelivery(
          conversationId: conversationId2,
          messageTimestamp: messageTimestamp,
          deliveredTime: deliveredTime,
        );
      }

      // If still not found, try without complex query (to avoid index requirement)
      if (!success) {
        debugPrint('🔍 Trying simple timestamp-based search...');
        success = await _findMessageSimple(
          conversationId1: conversationId1,
          conversationId2: conversationId2,
          messageTimestamp: messageTimestamp,
          deliveredTime: deliveredTime,
        );
      }

      return success;
    } catch (e) {
      debugPrint('❌ Error in confirmDeliveryDirectly: $e');
      return false;
    }
  }

  // Helper to update message delivery status
  static Future<bool> _updateMessageDelivery({
    required String conversationId,
    required String messageTimestamp,
    required String deliveredTime,
  }) async {
    try {
      final messageRef = _firestore
                    .collection(EnvConfig.firebaseChatsCollection)

          .doc(conversationId)
          .collection('messages')
          .doc(messageTimestamp);

      final messageDoc = await messageRef.get();

      if (!messageDoc.exists) {
        debugPrint('⚠️ Message not found in conversation: $conversationId');
        return false;
      }

      final data = messageDoc.data()!;

      // Check if already delivered
      if (data['delivered'] != null &&
          data['delivered'].toString().isNotEmpty &&
          data['delivered'] != '') {
        debugPrint('ℹ️ Message already delivered');
        return true;
      }

      // Update delivery status
      await messageRef.update({
        'delivered': deliveredTime,
        'status': 'delivered',
        'deliveryPending': false,
      });

      debugPrint('✅ Message delivery confirmed for conversation: $conversationId');
      return true;
    } catch (e) {
      debugPrint('⚠️ Error updating message in conversation $conversationId: $e');
      return false;
    }
  }

  // Simple message finder without complex queries (no index required)
  static Future<bool> _findMessageSimple({
    required String conversationId1,
    required String conversationId2,
    required String messageTimestamp,
    required String deliveredTime,
  }) async {
    try {
      final targetTimestamp = int.tryParse(messageTimestamp) ?? 0;

      // Try to get last 20 messages from first conversation
      final messages1 = await _firestore
                    .collection(EnvConfig.firebaseChatsCollection)

          .doc(conversationId1)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      // Check messages in first conversation
      for (final doc in messages1.docs) {
        final docTimestamp = int.tryParse(doc.id) ?? 0;

        // Check if timestamps are close (within 2 seconds)
        if ((docTimestamp - targetTimestamp).abs() < 2000) {
          debugPrint('🎯 Found matching message in $conversationId1');

          final data = doc.data();
          if (data['delivered'] != null &&
              data['delivered'].toString().isNotEmpty) {
            debugPrint('ℹ️ Message already delivered');
            return true;
          }

          await doc.reference.update({
            'delivered': deliveredTime,
            'status': 'delivered',
            'deliveryPending': false,
          });

          debugPrint('✅ Message updated successfully');
          return true;
        }
      }

      // Try second conversation if not found in first
      final messages2 = await _firestore
                    .collection(EnvConfig.firebaseChatsCollection)

          .doc(conversationId2)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      for (final doc in messages2.docs) {
        final docTimestamp = int.tryParse(doc.id) ?? 0;

        if ((docTimestamp - targetTimestamp).abs() < 2000) {
          debugPrint('🎯 Found matching message in $conversationId2');

          final data = doc.data();
          if (data['delivered'] != null &&
              data['delivered'].toString().isNotEmpty) {
            debugPrint('ℹ️ Message already delivered');
            return true;
          }

          await doc.reference.update({
            'delivered': deliveredTime,
            'status': 'delivered',
            'deliveryPending': false,
          });

          debugPrint('✅ Message updated successfully');
          return true;
        }
      }

      debugPrint('⚠️ Message not found in recent messages');
      return false;
    } catch (e) {
      debugPrint('❌ Error in simple finder: $e');
      return false;
    }
  }

  // Process all pending deliveries in batches
  static Future<void> processAllPendingDeliveries(String userId) async {
    try {
      if (userId.isEmpty) return;

      // Query active user conversations to avoid collectionGroup permission issues
      final myUsersSnapshot = await _firestore
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(userId)
          .collection('my_users')
          .get();

      if (myUsersSnapshot.docs.isEmpty) {
        debugPrint('No user conversations found for pending deliveries');
        return;
      }

      final batch = _firestore.batch();
      final deliveredTime = DateTime.now().millisecondsSinceEpoch.toString();
      int count = 0;

      for (final userDoc in myUsersSnapshot.docs) {
        final otherUserId = userDoc.id;
        final conversationId = _getConversationId(userId, otherUserId);

        final undeliveredMessages = await _firestore
            .collection(EnvConfig.firebaseChatsCollection)
            .doc(conversationId)
            .collection('messages')
            .where('toId', isEqualTo: userId)
            .get();

        for (final doc in undeliveredMessages.docs) {
          final data = doc.data();
          // Check if delivery is pending
          if (data['deliveryPending'] == true ||
              data['delivered'] == null ||
              data['delivered'] == '') {
            batch.update(doc.reference, {
              'delivered': deliveredTime,
              'status': 'delivered',
              'deliveryPending': false,
            });
            count++;
          }
        }
      }

      if (count > 0) {
        await batch.commit();
        debugPrint('✅ Processed $count pending deliveries');
      } else {
        debugPrint('No pending deliveries to process');
      }
    } catch (e) {
      debugPrint('❌ Error processing pending deliveries: $e');
    }
  }

  // Add sender to receiver's chat list
  static Future<void> addToChatList({
    required String senderId,
    required String receiverId,
    required String messageTimestamp,
  }) async {
    try {
      await _firestore
                    .collection(EnvConfig.firebaseUsersCollection)

          .doc(receiverId)
          .collection('my_users')
          .doc(senderId)
          .set({
        'last_message_time': messageTimestamp,
        'added_at': DateTime.now().millisecondsSinceEpoch.toString(),
        'unread_count': FieldValue.increment(1),
      }, SetOptions(merge: true));

      debugPrint('✅ Added $senderId to $receiverId\'s chat list');
    } catch (e) {
      debugPrint('❌ Error adding to chat list: $e');
    }
  }

  // Helper to generate consistent conversation ID
  static String _getConversationId(String userId1, String userId2) {
    return userId1.compareTo(userId2) <= 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }
}