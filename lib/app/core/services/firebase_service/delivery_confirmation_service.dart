
// ============================================
// 3. UPDATED delivery_confirmation_service.dart - Enhanced service
// ============================================

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeliveryConfirmationService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Enhanced cloud function call with retry
  static Future<bool> confirmDeliveryViaCloudFunction({
    required String senderId,
    required String receiverId,
    required String messageTimestamp,
  }) async {
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final HttpsCallable callable = _functions.httpsCallable(
          'confirmMessageDelivery',
          options: HttpsCallableOptions(
            timeout: const Duration(seconds: 15),
          ),
        );

        final result = await callable.call({
          'senderId': senderId,
          'receiverId': receiverId,
          'messageTimestamp': messageTimestamp,
        });

        if (result.data['success'] == true) {
          return true;
        }
      } catch (e) {
        debugPrint('Cloud function attempt ${attempt + 1} failed: $e');
        if (attempt == 0) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
    return false;
  }

  // Process all pending deliveries when app starts
  static Future<void> processAllPendingDeliveries(String userId) async {
    try {
      // Use collection group query for efficiency
      final pendingMessages = await FirebaseFirestore.instance
          .collectionGroup('messages')
          .where('toId', isEqualTo: userId)
          .where('deliveryPending', isEqualTo: true)
          .limit(100)
          .get();

      if (pendingMessages.docs.isEmpty) {
        debugPrint('No pending deliveries found');
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      final deliveredTime = DateTime.now().millisecondsSinceEpoch.toString();
      int count = 0;

      for (final doc in pendingMessages.docs) {
        batch.update(doc.reference, {
          'delivered': deliveredTime,
          'status': 'delivered',
          'deliveryPending': false,
        });
        count++;

        // Commit batch every 50 updates
        if (count % 50 == 0) {
          await batch.commit();
          debugPrint('✅ Batch committed: $count messages');
        }
      }

      // Commit remaining
      if (count % 50 != 0) {
        await batch.commit();
      }

      debugPrint('✅ Processed $count pending deliveries');
    } catch (e) {
      debugPrint('❌ Error processing pending deliveries: $e');
    }
  }
}