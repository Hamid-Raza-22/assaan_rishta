import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../core/export.dart';
import '../../core/services/firebase_service/export.dart';
import '../../domain/export.dart';



class ChatRepository {
  String get currentUserId => Get.find<UserManagementUseCase>().getUserId().toString();

  Future<void> getSelfInfo() => FirebaseService.getSelfInfo();

  Future<ChatUser?> getUserById(String uid, String imageUrl) =>
      FirebaseService.getUserById(uid, imageUrl);

  Future<bool> userExists(String uid) => FirebaseService.userExists(uid);

  Future<void> createUser({
    required String name,
    required String id,
    required String email,
    required String image,
    required bool isOnline,
    required bool isMobileOnline,
  }) =>
      FirebaseService.createUser(
        name: name,
        id: id,
        email: email,
        image: image,
        isOnline: isOnline,
        isMobileOnline: isMobileOnline,
      );

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId(String currentUID) =>
      FirebaseService.getMyUsersId(currentUID);

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds) =>
      FirebaseService.getAllUsers(userIds);

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(String uid) =>
      FirebaseService.getUserInfo(uid: uid);

  Future<bool> addChatUser(String uid) => FirebaseService.addChatUser(uid);

  Future<void> updateActiveStatus(bool isOnline) =>
      FirebaseService.updateActiveStatus(isOnline);

  Future<void> updateLastActive() => FirebaseService.updateLastActive();

  // Future<void> updateLastActiveOfReceiver(String receiverId) =>
  //     FirebaseService.updateLastActiveOfReceiver(receiverId);

  Future<void> insideChatStatus(bool isInside) =>
      FirebaseService.insideChatStatus(isInside);

  Future<void> updateFcmToken(String fcmToken) =>
      FirebaseService.updateFcmToken(fcmToken: fcmToken);

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) =>
      FirebaseService.getAllMessages(user);

  Future<void> sendMessage(ChatUser user, String msg, Type type) =>
      FirebaseService.sendMessage(user, msg, type);

  Future<void> sendFirstMessage(ChatUser user, String msg, Type type) =>
      FirebaseService().sendFirstMessage(user, msg, type);

  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user) =>
      FirebaseService.getLastMessage(user);

  Future<void> sendChatImage(String currentUID, ChatUser user, File file) =>
      FirebaseService.sendChatImage(currentUID, user, file);

  Future<void> deleteMessage(Message message) =>
      FirebaseService.deleteMessage(message);

  Future<void> updateMessage(Message message, String updatedMsg) =>
      FirebaseService.updateMessage(message, updatedMsg);

  Future<void> updateMessageReadStatus(Message message) =>
      FirebaseService.updateMessageReadStatus(message);

  Future<void> blockUser(String userIdToBlock) =>
      FirebaseService.blockUser(userIdToBlock);

  Future<void> unblockUser(String userIdToUnblock) =>
      FirebaseService.unblockUser(userIdToUnblock);

  Future<bool> isUserBlocked(String userId) =>
      FirebaseService.isUserBlocked(userId);

  Future<bool> isMyFriendBlocked(String userId) =>
      FirebaseService.isMyFriendBlocked(userId);
}

