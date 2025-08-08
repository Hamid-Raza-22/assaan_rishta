// enhanced_chat_user_card.dart - With deleted user detection

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

import '../core/export.dart';
import '../utils/exports.dart';
import '../viewmodels/chat_list_viewmodel.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../views/chat/export.dart';
import 'export.dart';

// Enhanced controller with deletion detection
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

  // ENHANCED: Deletion detection
  final RxBool isUserDeleted = false.obs;
  final RxString userDeletionTime = ''.obs;
  final RxBool isDeletionStatusLoaded = false.obs;

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

  StreamSubscription? _userStreamSubscription;
  StreamSubscription? _blockStatusSubscription;
  StreamSubscription? _blockedByOtherSubscription;

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
  }

  @override
  void onClose() {
    debugPrint('🗑️ Disposing ChatUserCardController for $userId');

    _userStreamSubscription?.cancel();
    _blockStatusSubscription?.cancel();
    _blockedByOtherSubscription?.cancel();

    _userStreamSubscription = null;
    _blockStatusSubscription = null;
    _blockedByOtherSubscription = null;

    super.onClose();
  }

  // ENHANCED: Check if user has deleted their account
  Future<void> _checkDeletionStatus() async {
    try {
      debugPrint('🔍 Checking deletion status for user: $userId');

      final userDoc = await FirebaseFirestore.instance
          .collection('Hamid_users')
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

  // ENHANCED: User data stream with deletion monitoring
  void _setupUserDataStream() {
    debugPrint('📺 Setting up ENHANCED user data stream for: $userId');

    _userStreamSubscription?.cancel();

    _userStreamSubscription = FirebaseFirestore.instance
        .collection('Hamid_users')
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

          // Update to show deleted user
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

          // Update deletion status
          if (accountDeleted != isUserDeleted.value) {
            isUserDeleted.value = accountDeleted;
            userDeletionTime.value = userData['deleted_at'] as String? ?? '';

            debugPrint('🔄 Deletion status changed for $userId: $accountDeleted');
          }

          // Update user data
          if (accountDeleted) {
            // Show deleted user info
            realtimeUserData.value = ChatUser.fromJson({
              ...userData,
              'name': 'Deleted User',
              'about': 'This account has been deleted',
              'image': '',
              'is_online': false,
              'is_mobile_online': false,
              'is_web_online': false,
            });
          } else {
            // Show normal user info
            final updatedUser = ChatUser.fromJson(userData);
            _preloadUserImage(updatedUser.image);
            realtimeUserData.value = updatedUser;
          }

          debugPrint('🔄 REAL-TIME UPDATE: ${realtimeUserData.value.name} | Deleted: $accountDeleted | Online: ${realtimeUserData.value.isOnline}');

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

  void _preloadUserImage(String imageUrl) {
    if (imageUrl.isEmpty || imageUrl == AppConstants.profileImg) {
      return;
    }

    try {
      CachedNetworkImage.evictFromCache(imageUrl).then((_) {
        precacheImage(
          CachedNetworkImageProvider(imageUrl),
          Get.context!,
        ).catchError((e) {
          debugPrint('🖼️ Error preloading image: $e');
        });
      });

      debugPrint('🖼️ Preloading image for user: $userId');
    } catch (e) {
      debugPrint('❌ Error in image preloading: $e');
    }
  }

  void _setupBlockStatusListeners() {
    _blockStatusSubscription?.cancel();
    _blockedByOtherSubscription?.cancel();

    _blockStatusSubscription = FirebaseFirestore.instance
        .collection('Hamid_users')
        .doc(currentUID)
        .snapshots()
        .listen(
          (snapshot) {
        if (!Get.isRegistered<ChatUserCardController>(tag: 'chat_card_$userId')) {
          return;
        }

        if (!snapshot.exists) return;

        final userData = snapshot.data();
        // final blockedUsers = userData?['blockedUsers'] as Map<String, dynamic>? ?? {};
        final blockedUsersData = userData?['blockedUsers'];
        Map<String, dynamic> blockedUsers = {};
        if (blockedUsersData is Map<String, dynamic>) {
          debugPrint('📱 [My Block List] blockedUsers is a Map: $blockedUsersData');
          blockedUsers = blockedUsersData;
        } else if (blockedUsersData is List) {
          debugPrint('📱 [My Block List] blockedUsers is a List, converting: $blockedUsersData');
          // Handle case where it might be a list of UIDs, convert to map for consistency
          blockedUsers = {for (var item in blockedUsersData) item.toString(): null};
        }

        final wasBlocked = hasBlockedThem.value;
        hasBlockedThem.value = blockedUsers.containsKey(userId);

        debugPrint('📱 Block status updated - User $userId blocked by me: ${hasBlockedThem.value}');

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
        .collection('Hamid_users')
        .doc(userId)
        .snapshots()
        .listen(
          (snapshot) {
        if (!Get.isRegistered<ChatUserCardController>(tag: 'chat_card_$userId')) {
          return;
        }

        if (!snapshot.exists) return;

        final userData = snapshot.data();
        // final blockedUsers = userData?['blockedUsers'] as Map<String, dynamic>? ?? {};
        final blockedUsersData = userData?['blockedUsers'];
        Map<String, dynamic> blockedUsers = {};
        if (blockedUsersData is Map<String, dynamic>) {
          debugPrint('👤 [Other User Block List] blockedUsers is a Map: $blockedUsersData');
          blockedUsers = blockedUsersData;
        } else if (blockedUsersData is List) {
          debugPrint('👤 [Other User Block List] blockedUsers is a List, converting: $blockedUsersData');
          blockedUsers = {for (var item in blockedUsersData) item.toString(): null};
        }

        final wasBlockedByOther = isBlockedByOther.value;
        isBlockedByOther.value = blockedUsers.containsKey(currentUID);

        debugPrint('👤 Blocked by other status updated - User $userId blocked me: ${isBlockedByOther.value}');

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

  // ENHANCED: Helper getters with deletion check
  bool get isCurrentlyBlocked => hasBlockedThem.value || isBlockedByOther.value;
  bool get isCurrentlyDeleted => isUserDeleted.value;
  bool get canChat => !isCurrentlyBlocked && !isCurrentlyDeleted;
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

// ENHANCED: ChatUserCard with deletion support
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
          child: _buildCardContent(controller),
        ),
      ),
    );
  }

  // ENHANCED: Card content with deletion status
  Widget _buildCardContent(ChatUserCardController controller) {
    return GetBuilder<ChatUserCardController>(
      tag: 'chat_card_${user.id}',
      id: 'user_data_${user.id}',
      builder: (ctrl) {
        return Obx(() {
          final displayUser = ctrl.currentUserData;
          final isBlocked = ctrl.isCurrentlyBlocked;
          final isDeleted = ctrl.isCurrentlyDeleted;

          debugPrint('🎨 Building card UI for: ${displayUser.name} (${displayUser.id}) - Deleted: $isDeleted');

          return ListTile(
            leading: _buildAvatar(isBlocked, isDeleted, displayUser),
            title: _buildTitle(isDeleted, displayUser, ctrl),
            subtitle: _buildSubtitle(ctrl.listController, isBlocked, isDeleted, displayUser, ctrl),
            trailing: _buildTrailing(ctrl.listController, isBlocked, isDeleted, ctrl),
          );
        });
      },
    );
  }

  // ENHANCED: Avatar with deletion indication
  Widget _buildAvatar(bool isBlocked, bool isDeleted, ChatUser displayUser) {
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
                ? displayUser.image
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
            cacheManager: DefaultCacheManager(),
            memCacheHeight: 100,
            memCacheWidth: 100,
            fadeInDuration: const Duration(milliseconds: 200),
            fadeOutDuration: const Duration(milliseconds: 200),
          ),
        ),
        if (!isBlocked && !isDeleted && displayUser.isOnline)
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

  // ENHANCED: Title with deletion status
  Widget _buildTitle(bool isDeleted, ChatUser displayUser, ChatUserCardController controller) {
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

    return Text(
      displayUser.name,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  // ENHANCED: Subtitle with deletion information
  Widget _buildSubtitle(ChatListController controller, bool isBlocked, bool isDeleted,
      ChatUser displayUser, ChatUserCardController cardController) {
    if (isDeleted) {
      return Text(
        'Account deleted ${cardController.displayDeletionTime}',
        style: const TextStyle(fontSize: 14, color: Colors.red, fontStyle: FontStyle.italic),
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

    return Obx(() {
      final lastMessage = controller.getLastMessageReactive(user.id).value;

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
            if (isMe) _buildTickIcon(lastMessage.read.isNotEmpty),
            const Icon(Icons.image_rounded, color: Colors.grey, size: 16),
            const SizedBox(width: 4),
            const Text('Photo', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        );
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMe) _buildTickIcon(lastMessage.read.isNotEmpty),
          Flexible(
            child: Text(
              lastMessage.msg,
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
  }

  // ENHANCED: Trailing with deletion status
  Widget _buildTrailing(ChatListController controller, bool isBlocked, bool isDeleted,
      ChatUserCardController cardController) {
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
      final lastMessage = controller.getLastMessageReactive(user.id).value;
      if (lastMessage == null) return const SizedBox.shrink();

      final isUnread = lastMessage.read.isEmpty && lastMessage.fromId != currentUID;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            MyDateUtill.getLastMessageTime(Get.context!, lastMessage.sent),
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

  Widget _buildTickIcon(bool isRead) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Icon(
        Icons.done_all_rounded,
        color: isRead ? Colors.blue : Colors.grey,
        size: 16,
      ),
    );
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
    // Don't allow navigation to deleted users
    // if (controller.isCurrentlyDeleted) {
    //   _showDeletedUserDialog(context, controller);
    //   return;
    // }

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

  // ENHANCED: Show dialog when trying to interact with deleted user
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