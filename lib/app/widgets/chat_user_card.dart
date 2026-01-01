// enhanced_chat_user_card.dart - With real-time message status updates

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

import '../core/export.dart';
import '../core/services/env_config_service.dart';
import '../utils/exports.dart';
import '../viewmodels/chat_list_viewmodel.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../views/chat/chatting_view.dart';
import '../views/chat/export.dart';

// Enhanced controller with real-time status updates
class ChatUserCardController extends GetxController {
  final String userId;
  final String currentUID;
  final ChatUser user;

  ChatUserCardController({
    required this.userId,
    required this.currentUID,
    required this.user,
  });

  late final ChatListController listController;
  late final ChatViewModel chatViewModel;

  final RxBool isBlockedByOther = false.obs;
  final RxBool hasBlockedThem = false.obs;
  final RxBool isBlockStatusLoaded = false.obs;

  // Deletion detection
  final RxBool isUserDeleted = false.obs;
  final RxString userDeletionTime = ''.obs;
  final RxBool isDeletionStatusLoaded = false.obs;
  
  // Deactivation detection
  final RxBool isUserDeactivated = false.obs;

  // Real-time user data with better reactivity
  final Rx<ChatUser> realtimeUserData = Rx<ChatUser>(ChatUser(
    id: '',
    name: '',
    email: '',
    about: '',
    image: '',
    createdAt: '',
    isOnline: false,
    lastActive: '',
    pushToken: '',
    lastMessage: '',
    isInside: false,
    isMobileOnline: false,
    isWebOnline: false,
  ));

  // Enhanced: Message status tracking
  final Rx<Message?> lastMessage = Rx<Message?>(null);
  final RxString lastMessageTime = ''.obs;
  final Rx<MessageStatus?> lastMessageStatus = Rx<MessageStatus?>(null);

  StreamSubscription? _userStreamSubscription;
  StreamSubscription? _blockStatusSubscription;
  StreamSubscription? _blockedByOtherSubscription;
  StreamSubscription? _messageStreamSubscription;
  StreamSubscription? _statusUpdateSubscription;

  @override
  void onInit() {
    super.onInit();

    if (!Get.isRegistered<ChatViewModel>()) {
      Get.put(ChatViewModel());
      debugPrint('💬 ChatViewModel created in ChatUserCard');
    }

    listController = Get.find<ChatListController>();
    chatViewModel = Get.find<ChatViewModel>();

    // Initialize with cached user data
    realtimeUserData.value = user;
    _preloadUserImage(user.image);

    // Check deletion and block status
    _checkBlockStatus();
    _checkDeletionStatus();

    // Setup real-time listeners
    _setupBlockStatusListeners();
    _setupUserDataStream();

    // NEW: Setup enhanced message listener with status tracking
    _setupEnhancedMessageListener();
  }

  @override
  void onClose() {
    debugPrint('🗑️ Disposing ChatUserCardController for $userId');

    _userStreamSubscription?.cancel();
    _blockStatusSubscription?.cancel();
    _blockedByOtherSubscription?.cancel();
    _messageStreamSubscription?.cancel();
    _statusUpdateSubscription?.cancel();

    _userStreamSubscription = null;
    _blockStatusSubscription = null;
    _blockedByOtherSubscription = null;
    _messageStreamSubscription = null;
    _statusUpdateSubscription = null;

    super.onClose();
  }

  // NEW: Enhanced message listener that tracks status changes
  void _setupEnhancedMessageListener() {
    _messageStreamSubscription?.cancel();

    final chatId = getConversationId(currentUID, userId);

    _messageStreamSubscription = FirebaseFirestore.instance
                  .collection(EnvConfig.firebaseChatsCollection)

        .doc(chatId)
        .collection('messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {

      if (snapshot.docs.isNotEmpty) {
        final messageData = snapshot.docs.first.data();
        final message = Message.fromJson(messageData);

        // Check if message should be shown (after deletion)
        final deletionTime = listController.deletionTimestamps[userId];
        if (deletionTime != null) {
          final messageTime = int.parse(message.sent);
          final deletedAt = int.parse(deletionTime);

          if (messageTime <= deletedAt) {
            lastMessage.value = null;
            lastMessageTime.value = '0';
            lastMessageStatus.value = null;
            return;
          }
        }

        // Update message and its status
        lastMessage.value = message;
        lastMessageTime.value = message.sent;

        // Parse and update message status
        lastMessageStatus.value = _parseMessageStatus(message);

        // Update position in list if needed
        _updateUserPositionIfNeeded(message.sent);

        // Force UI refresh
        update(['message_status_$userId', 'last_message_$userId']);

        debugPrint('📊 Updated message status for $userId: ${lastMessageStatus.value}');
      }
    });

    // Also listen for status updates on existing messages
    _setupStatusUpdateListener();
  }

  // NEW: Listen for status updates on the last message
  void _setupStatusUpdateListener() {
    _statusUpdateSubscription?.cancel();

    final chatId = getConversationId(currentUID, userId);

    // Listen to the entire messages collection for status changes
    _statusUpdateSubscription = FirebaseFirestore.instance
                  .collection(EnvConfig.firebaseChatsCollection)

        .doc(chatId)
        .collection('messages')
        .snapshots()
        .listen((snapshot) {

      // Check if we have a last message to update
      if (lastMessage.value == null) return;

      // Find our last message in the snapshot
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data()!;

          // Check if this is our last message
          if (data['sent'] == lastMessage.value!.sent) {
            // Update the status
            final newStatus = _parseMessageStatus(Message.fromJson(data));

            if (newStatus != lastMessageStatus.value) {
              lastMessageStatus.value = newStatus;

              // Update the message object
              lastMessage.value = Message.fromJson(data);

              // Force UI update
              update(['message_status_$userId', 'last_message_$userId']);

              debugPrint('✅ Status updated in card for message ${data['sent']}: $newStatus');
            }
          }
        }
      }
    });
  }

  // NEW: Parse message status from message data
  MessageStatus _parseMessageStatus(Message message) {
    // For received messages
    if (message.fromId != currentUID) {
      return MessageStatus.delivered; // Received messages show as delivered
    }

    // For sent messages
    if (message.read.isNotEmpty) {
      return MessageStatus.read;
    } else if (message.delivered != null && message.delivered!.isNotEmpty) {
      return MessageStatus.delivered;
    } else    // Use explicit status if set
    return message.status;
  
  }

  // Check if user has deleted their account
  Future<void> _checkDeletionStatus() async {
    try {
      debugPrint('🔍 Checking deletion status for user: $userId');

      final userDoc = await FirebaseFirestore.instance
                    .collection(EnvConfig.firebaseUsersCollection)

          .doc(userId)
          .get();

      if (!userDoc.exists) {
        debugPrint('👤 User document does not exist: $userId');
        isUserDeleted.value = true;
        userDeletionTime.value = 'Unknown';
        isDeletionStatusLoaded.value = true;
        return;
      }

      final userData = userDoc.data()!;
      final accountDeleted = userData['account_deleted'] == true;
      final deletionTimestamp = userData['deleted_at'] as String? ?? '';

      isUserDeleted.value = accountDeleted;
      userDeletionTime.value = deletionTimestamp;
      isDeletionStatusLoaded.value = true;

      if (accountDeleted) {
        debugPrint('🗑️ User $userId has deleted their account at: $deletionTimestamp');

        // Update realtime user data to show deletion status
        realtimeUserData.value = realtimeUserData.value.copyWith(
          name: 'Deleted User',
          about: 'This account has been deleted',
          image: '',
          isOnline: false,
        );
      }

    } catch (e) {
      debugPrint('❌ Error checking deletion status: $e');
      isDeletionStatusLoaded.value = true;
    }
  }

  Future<void> _checkBlockStatus() async {
    try {
      final results = await Future.wait([
        chatViewModel.isBlockedByFriend(userId),
        chatViewModel.isUserBlocked(userId),
      ]);

      isBlockedByOther.value = results[0];
      hasBlockedThem.value = results[1];
      isBlockStatusLoaded.value = true;

      debugPrint('🔍 Block status checked - BlockedByOther: ${isBlockedByOther.value}, HasBlockedThem: ${hasBlockedThem.value}');

    } catch (e) {
      debugPrint('Error checking block status: $e');
      isBlockStatusLoaded.value = true;
    }
  }

  void _setupUserDataStream() {
    debugPrint('📺 Setting up user data stream for: $userId');

    _userStreamSubscription?.cancel();

    _userStreamSubscription = FirebaseFirestore.instance
                  .collection(EnvConfig.firebaseUsersCollection)

        .doc(userId)
        .snapshots()
        .listen(
          (DocumentSnapshot<Map<String, dynamic>> snapshot) {

        if (!Get.isRegistered<ChatUserCardController>(tag: 'chat_card_$userId')) {
          debugPrint('⚠️ Controller no longer registered, canceling stream');
          _userStreamSubscription?.cancel();
          return;
        }

        if (!snapshot.exists) {
          debugPrint('👤 User document deleted: $userId');
          isUserDeleted.value = true;
          userDeletionTime.value = DateTime.now().millisecondsSinceEpoch.toString();

          realtimeUserData.value = realtimeUserData.value.copyWith(
            name: 'Deleted User',
            about: 'This account no longer exists',
            image: '',
            isOnline: false,
          );

          update(['user_data_$userId']);
          return;
        }

        try {
          final userData = snapshot.data()!;
          final accountDeleted = userData['account_deleted'] == true;
          final accountDeactivated = userData['is_deactivated'] == true;

          if (accountDeleted != isUserDeleted.value) {
            isUserDeleted.value = accountDeleted;
            userDeletionTime.value = userData['deleted_at'] as String? ?? '';

            debugPrint('🔄 Deletion status changed for $userId: $accountDeleted');
          }
          
          if (accountDeactivated != isUserDeactivated.value) {
            isUserDeactivated.value = accountDeactivated;
            debugPrint('🔄 Deactivation status changed for $userId: $accountDeactivated');
          }

          if (accountDeleted) {
            realtimeUserData.value = ChatUser.fromJson({
              ...userData,
              'name': 'Deleted User',
              'about': 'This account has been deleted',
              'image': '',
              'is_online': false,
              'is_mobile_online': false,
              'is_web_online': false,
            });
          } else if (accountDeactivated) {
            realtimeUserData.value = ChatUser.fromJson({
              ...userData,
              'name': userData['name'] ?? 'Deactivated User',
              'about': 'This account is deactivated',
              'is_online': false,
              'is_mobile_online': false,
              'is_web_online': false,
            });
          } else {
            final updatedUser = ChatUser.fromJson(userData);
            _preloadUserImage(updatedUser.image);
            realtimeUserData.value = updatedUser;
          }

          debugPrint('🔄 REAL-TIME UPDATE: ${realtimeUserData.value.name} | Deleted: $accountDeleted | Deactivated: $accountDeactivated | Online: ${realtimeUserData.value.isOnline}');

          update(['user_data_$userId']);

        } catch (e) {
          debugPrint('❌ Error parsing user data: $e');
        }
      },
      onError: (error) {
        debugPrint('❌ User data stream error: $error');
      },
      cancelOnError: false,
    );
  }

  void _updateUserPositionIfNeeded(String messageTime) {
    // Let the ChatListController handle position updates
    listController.forceUpdateUserPosition(userId);
  }

  String getConversationId(String userId1, String userId2) {
    return userId1.compareTo(userId2) <= 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  void _preloadUserImage(String imageUrl) {
    if (imageUrl.isEmpty || imageUrl == AppConstants.profileImg) {
      return;
    }

    try {
      // Sanitize URL to remove staging prefix
      final sanitizedUrl = AppUtils.sanitizeImageUrl(imageUrl);
      
      // Don't evict from cache, just preload if not cached
      final ctx = Get.context;
      if (ctx == null) {
        return;
      }
      
      // Use errorListener to suppress 404 errors
      precacheImage(
        CachedNetworkImageProvider(
          sanitizedUrl,
          errorListener: (error) {
            // Silently handle 404 and other HTTP errors
            debugPrint('🖼️ Image not available: $sanitizedUrl');
          },
        ),
        ctx,
        onError: (exception, stackTrace) {
          // Silently handle preloading errors (404, network issues, etc.)
          debugPrint('🖼️ Preload failed for: $sanitizedUrl');
        },
      );
    } catch (e) {
      // Silently catch any other errors
      debugPrint('❌ Error in image preloading: $e');
    }
  }

  void _setupBlockStatusListeners() {
    _blockStatusSubscription?.cancel();
    _blockedByOtherSubscription?.cancel();

    _blockStatusSubscription = FirebaseFirestore.instance
                  .collection(EnvConfig.firebaseUsersCollection)

        .doc(currentUID)
        .snapshots()
        .listen(
          (snapshot) {
        if (!Get.isRegistered<ChatUserCardController>(tag: 'chat_card_$userId')) {
          return;
        }

        if (!snapshot.exists) return;

        final userData = snapshot.data();
        final blockedUsersData = userData?['blockedUsers'];
        Map<String, dynamic> blockedUsers = {};

        if (blockedUsersData is Map<String, dynamic>) {
          blockedUsers = blockedUsersData;
        } else if (blockedUsersData is List) {
          blockedUsers = {for (var item in blockedUsersData) item.toString(): null};
        }

        final wasBlocked = hasBlockedThem.value;
        hasBlockedThem.value = blockedUsers.containsKey(userId);

        if (wasBlocked != hasBlockedThem.value) {
          update(['block_status_$userId']);
        }
      },
      onError: (error) {
        debugPrint('❌ Error in my block status stream: $error');
      },
      cancelOnError: false,
    );

    _blockedByOtherSubscription = FirebaseFirestore.instance
                  .collection(EnvConfig.firebaseUsersCollection)

        .doc(userId)
        .snapshots()
        .listen(
          (snapshot) {
        if (!Get.isRegistered<ChatUserCardController>(tag: 'chat_card_$userId')) {
          return;
        }

        if (!snapshot.exists) return;

        final userData = snapshot.data();
        final blockedUsersData = userData?['blockedUsers'];
        Map<String, dynamic> blockedUsers = {};

        if (blockedUsersData is Map<String, dynamic>) {
          blockedUsers = blockedUsersData;
        } else if (blockedUsersData is List) {
          blockedUsers = {for (var item in blockedUsersData) item.toString(): null};
        }

        final wasBlockedByOther = isBlockedByOther.value;
        isBlockedByOther.value = blockedUsers.containsKey(currentUID);

        if (wasBlockedByOther != isBlockedByOther.value) {
          update(['block_status_$userId']);
        }
      },
      onError: (error) {
        debugPrint('❌ Error in blocked by other stream: $error');
      },
      cancelOnError: false,
    );
  }

  Future<void> handleBlock() async {
    debugPrint('🚫 Blocking user $userId');
    await chatViewModel.blockUser(userId);
    hasBlockedThem.value = true;
    update(['block_status_$userId']);
  }

  Future<void> handleUnblock() async {
    debugPrint('✅ Unblocking user $userId');
    await chatViewModel.unblockUser(userId);
    hasBlockedThem.value = false;
    update(['block_status_$userId']);
  }

  // Helper getters
  bool get isCurrentlyBlocked => hasBlockedThem.value || isBlockedByOther.value;
  bool get isCurrentlyDeleted => isUserDeleted.value;
  bool get isCurrentlyDeactivated => isUserDeactivated.value;
  bool get canChat => !isCurrentlyBlocked && !isCurrentlyDeleted && !isCurrentlyDeactivated;
  ChatUser get currentUserData => realtimeUserData.value;

  String get displayDeletionTime {
    if (userDeletionTime.value.isEmpty || userDeletionTime.value == 'Unknown') {
      return 'Recently';
    }

    try {
      final deletionTimestamp = int.parse(userDeletionTime.value);
      final deletionDate = DateTime.fromMillisecondsSinceEpoch(deletionTimestamp);
      final now = DateTime.now();
      final difference = now.difference(deletionDate);

      if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else {
        return 'Recently';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}

// Enhanced ChatUserCard widget
class EnhancedChatUserCard extends StatelessWidget {
  final String currentUID;
  final ChatUser user;

  const EnhancedChatUserCard({
    super.key,
    required this.user,
    required this.currentUID,
  });

  @override
  Widget build(BuildContext context) {
    final String tag = 'chat_card_${user.id}';

    if (!Get.isRegistered<ChatUserCardController>(tag: tag)) {
      Get.put(
        ChatUserCardController(
          userId: user.id,
          currentUID: currentUID,
          user: user,
        ),
        tag: tag,
      );
    }

    final controller = Get.find<ChatUserCardController>(tag: tag);
    final size = MediaQuery.of(context).size;

    return Dismissible(
      key: Key('dismissible_${user.id}'),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (direction) => _showDeleteConfirmDialog(context, controller),
      onDismissed: (direction) {
        if (Get.isRegistered<ChatUserCardController>(tag: tag)) {
          Get.delete<ChatUserCardController>(tag: tag, force: true);
        }
        controller.listController.deleteChat(user);
      },
      child: Card(
        key: ValueKey('chat_card_${user.id}'),
        color: const Color(0xFFF6F6F6),
        margin: EdgeInsets.symmetric(
          horizontal: size.width * .03,
          vertical: 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: () => _navigateToChat(context, controller),
          onLongPress: () => _showOptions(context, controller),
          child: _buildCardContent(context, controller),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, ChatUserCardController controller) {
    return GetBuilder<ChatUserCardController>(
      tag: 'chat_card_${user.id}',
      id: 'last_message_${user.id}',
      init: controller,
      builder: (ctrl) {
        return Obx(() {
          final displayUser = ctrl.currentUserData;
          final isBlocked = ctrl.isCurrentlyBlocked;
          final isDeleted = ctrl.isCurrentlyDeleted;
          final isDeactivated = ctrl.isCurrentlyDeactivated;

          debugPrint('🎨 Building card UI for: ${displayUser.name} (${displayUser.id}) - Deleted: $isDeleted - Deactivated: $isDeactivated');

          return ListTile(
            leading: _buildAvatar(isBlocked, isDeleted, isDeactivated, displayUser),
            title: _buildTitle(isDeleted, isDeactivated, displayUser, ctrl),
            subtitle: _buildSubtitle(ctrl, isBlocked, isDeleted, isDeactivated, displayUser),
            trailing: _buildTrailing(context, ctrl, isBlocked, isDeleted, isDeactivated),
          );
        });
      },
    );
  }

  Widget _buildAvatar(bool isBlocked, bool isDeleted, bool isDeactivated, ChatUser displayUser) {
    if (isDeleted) {
      return Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            child: Icon(
              Icons.person_off,
              color: Colors.grey[500],
              size: 30,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.red,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 8,
              ),
            ),
          ),
        ],
      );
    }
    
    if (isDeactivated) {
      return Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            child: Icon(
              Icons.person_off_outlined,
              color: Colors.grey[500],
              size: 30,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.orange,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.pause,
                color: Colors.white,
                size: 8,
              ),
            ),
          ),
        ],
      );
    }

    if (isBlocked) {
      return CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.block, color: Colors.grey, size: 30),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: CachedNetworkImage(
            imageUrl: displayUser.image.isNotEmpty
                ? AppUtils.sanitizeImageUrl(displayUser.image)
                : AppConstants.profileImg,
            height: 50,
            width: 50,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.grey,
                size: 30,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.grey,
                size: 30,
              ),
            ),
            errorListener: (error) {
              // Silently handle 404 and other image loading errors
              debugPrint('🖼️ Avatar image error: ${displayUser.id}');
            },
            cacheManager: DefaultCacheManager(),
            memCacheHeight: 100,
            memCacheWidth: 100,
            fadeInDuration: const Duration(milliseconds: 200),
            fadeOutDuration: const Duration(milliseconds: 200),
          ),
        ),
        if (!isBlocked && !isDeleted && !isDeactivated && displayUser.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.green,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(bool isDeleted, bool isDeactivated, ChatUser displayUser, ChatUserCardController controller) {
    if (isDeleted) {
      return Row(
        children: [
          const Expanded(
            child: Text(
              'Deleted User',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: const Text(
              'DELETED',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      );
    }
    
    if (isDeactivated) {
      return Row(
        children: [
          Expanded(
            child: Text(
              displayUser.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Text(
              'DEACTIVATED',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      displayUser.name,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  // ENHANCED: Subtitle with real-time status
  Widget _buildSubtitle(ChatUserCardController controller, bool isBlocked, bool isDeleted, bool isDeactivated,
      ChatUser displayUser) {
    if (isDeleted) {
      return Text(
        'Account deleted ${controller.displayDeletionTime}',
        style: const TextStyle(fontSize: 14, color: Colors.red, fontStyle: FontStyle.italic),
        overflow: TextOverflow.ellipsis,
      );
    }
    
    if (isDeactivated) {
      return const Text(
        'This account is deactivated',
        style: TextStyle(fontSize: 14, color: Colors.orange, fontStyle: FontStyle.italic),
        overflow: TextOverflow.ellipsis,
      );
    }

    if (isBlocked) {
      return const Text(
        'Account not available',
        style: TextStyle(fontSize: 14, color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      );
    }

    return GetBuilder<ChatUserCardController>(
      tag: 'chat_card_${user.id}',
      id: 'message_status_${user.id}',
      init: controller,
      builder: (ctrl) {
        return Obx(() {
          final lastMessage = ctrl.lastMessage.value;

          if (lastMessage == null) {
            return Text(
              displayUser.about,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            );
          }

          final isMe = lastMessage.fromId == currentUID;

          if (lastMessage.type == Type.image) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMe) _buildMessageStatusIcon(ctrl.lastMessageStatus.value, isMe),
                const Icon(Icons.image_rounded, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                const Text('Photo', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            );
          }

          // Handle reply messages
          String messageText = lastMessage.msg;
          if (messageText.contains('↪️')) {
            final parts = messageText.split('\n\n');
            if (parts.length > 1) {
              messageText = parts.sublist(1).join('\n\n');
            }
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMe) _buildMessageStatusIcon(ctrl.lastMessageStatus.value, isMe),
              Flexible(
                child: Text(
                  messageText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: lastMessage.read.isEmpty && !isMe
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  // NEW: Build message status icon (matching the one in message_card.dart)
  Widget _buildMessageStatusIcon(MessageStatus? status, bool isMe) {
    if (!isMe || status == null) return const SizedBox.shrink();

    IconData icon;
    Color color;
    double size = 14;

    switch (status) {
      case MessageStatus.pending:
        icon = Icons.access_time;
        color = Colors.grey;
        break;
      case MessageStatus.sent:
        icon = Icons.done;
        color = Colors.grey;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = const Color(0xFF4FC3F7);
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Icon(icon, color: color, size: size),
    );
  }

  Widget _buildTrailing(BuildContext context, ChatUserCardController controller, bool isBlocked, bool isDeleted, bool isDeactivated) {
    if (isDeleted) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.person_off, color: Colors.grey[400], size: 20),
          const SizedBox(height: 2),
          Text(
            'Gone',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    
    if (isDeactivated) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.pause_circle_outline, color: Colors.orange[400], size: 20),
          const SizedBox(height: 2),
          Text(
            'Paused',
            style: TextStyle(
              fontSize: 10,
              color: Colors.orange[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (isBlocked) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.block, color: Colors.red, size: 24),
          SizedBox(height: 2),
        ],
      );
    }

    return Obx(() {
      final lastMessage = controller.lastMessage.value;
      if (lastMessage == null) return const SizedBox.shrink();

      final isUnread = lastMessage.read.isEmpty && lastMessage.fromId != currentUID;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            MyDateUtill.getLastMessageTime(context, lastMessage.sent),
            style: TextStyle(
              fontSize: 12,
              color: isUnread ? Colors.green : Colors.grey,
              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (isUnread) ...[
            const SizedBox(height: 2),
            Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.green,
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_forever, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context, ChatUserCardController controller) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text('Delete Chat'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete your chat with ${controller.currentUserData.name}?\n\nThis action cannot be undone and all messages will be permanently deleted.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToChat(BuildContext context, ChatUserCardController controller) async {
    if (!Get.isRegistered<ChatViewModel>()) {
      Get.put(ChatViewModel());
      debugPrint('💬 ChatViewModel was not registered, now created.');
    }

    final chatController = Get.find<ChatViewModel>();
    chatController.setInsideChatStatus(true);

    bool? isBlocked;
    bool? isBlockedByOther;

    try {
      final results = await Future.wait([
        chatController.isUserBlocked(user.id),
        chatController.isBlockedByFriend(user.id),
      ]);

      isBlocked = results[0];
      isBlockedByOther = results[1];
    } catch (e) {
      debugPrint('Error fetching block status: $e');
    }

    Get.to(() => ChattingView(
      user: controller.currentUserData,
      isBlocked: isBlocked,
      isBlockedByOther: isBlockedByOther,
      isDeleted: controller.isCurrentlyDeleted,
    ))?.then((_) {
      chatController.setInsideChatStatus(false);
    });
  }

  void _showOptions(BuildContext context, ChatUserCardController controller) async {
    if (controller.isCurrentlyDeleted) {
      _showDeletedUserDialog(context, controller);
      return;
    }
    
    if (controller.isCurrentlyDeactivated) {
      _showDeactivatedUserDialog(context, controller);
      return;
    }

    final chatController = Get.find<ChatViewModel>();
    final isBlocked = await chatController.isUserBlocked(user.id);

    if (context.mounted) {
      showBlockUnblockBottomSheet(
        context: context,
        userId: user.id,
        isBlocked: isBlocked,
        onBlock: () async {
          await controller.handleBlock();
        },
        onUnblock: () async {
          await controller.handleUnblock();
        },
      );
    }
  }

  void _showDeletedUserDialog(BuildContext context, ChatUserCardController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.person_off, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text('Account Deleted'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This user has deleted their account.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text(
                'Account was deleted ${controller.displayDeletionTime}.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              const Text(
                'You can no longer send messages to this user.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Okay', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally delete this chat from list
                _showDeleteConfirmDialog(context, controller).then((shouldDelete) {
                  if (shouldDelete == true) {
                    controller.listController.deleteChat(user);
                    if (Get.isRegistered<ChatUserCardController>(tag: 'chat_card_${user.id}')) {
                      Get.delete<ChatUserCardController>(tag: 'chat_card_${user.id}', force: true);
                    }
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Remove Chat', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
  
  void _showDeactivatedUserDialog(BuildContext context, ChatUserCardController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            children: [
              Icon(Icons.pause_circle_outline, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text('Account Deactivated'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This user has temporarily deactivated their account.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text(
                'The user can reactivate their account at any time.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              const Text(
                'You cannot send messages while the account is deactivated.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Okay', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally delete this chat from list
                _showDeleteConfirmDialog(context, controller).then((shouldDelete) {
                  if (shouldDelete == true) {
                    controller.listController.deleteChat(user);
                    if (Get.isRegistered<ChatUserCardController>(tag: 'chat_card_${user.id}')) {
                      Get.delete<ChatUserCardController>(tag: 'chat_card_${user.id}', force: true);
                    }
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Remove Chat', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

// Extension to add copyWith method to ChatUser if not already present
extension ChatUserExtension on ChatUser {
  ChatUser copyWith({
    String? id,
    String? name,
    String? email,
    String? about,
    String? image,
    String? createdAt,
    bool? isOnline,
    String? lastActive,
    String? pushToken,
    String? lastMessage,
    bool? isInside,
    bool? isMobileOnline,
    bool? isWebOnline,
  }) {
    return ChatUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      about: about ?? this.about,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      pushToken: pushToken ?? this.pushToken,
      lastMessage: lastMessage ?? this.lastMessage,
      isInside: isInside ?? this.isInside,
      isMobileOnline: isMobileOnline ?? this.isMobileOnline,
      isWebOnline: isWebOnline ?? this.isWebOnline,
    );
  }
}