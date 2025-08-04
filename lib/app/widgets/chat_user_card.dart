// chat_user_card.dart - FIXED: Real-time user name and image updates (Enhanced Version)

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

// Controller for managing ChatUserCard state
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

  // ENHANCED: Real-time user data with better reactivity
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
    // ADDED: Preload initial image
    _preloadUserImage(user.image);

    // Check block status once on init
    _checkBlockStatus();

    // Setup real-time listeners
    _setupBlockStatusListeners();
    _setupUserDataStream();
  }

  @override
  void onClose() {
    debugPrint('🗑️ Disposing ChatUserCardController for $userId');

    // Cancel all subscriptions
    _userStreamSubscription?.cancel();
    _blockStatusSubscription?.cancel();
    _blockedByOtherSubscription?.cancel();

    // Clear references
    _userStreamSubscription = null;
    _blockStatusSubscription = null;
    _blockedByOtherSubscription = null;

    super.onClose();
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

  // ENHANCED: Direct document listener for better real-time updates
  void _setupUserDataStream() {
    debugPrint('📺 Setting up DIRECT user data stream for: $userId');

    _userStreamSubscription?.cancel();

    _userStreamSubscription = FirebaseFirestore.instance
        .collection('Hamid_users')
        .doc(userId) // DIRECT document listener
        .snapshots()
        .listen(
          (DocumentSnapshot<Map<String, dynamic>> snapshot) {

        // Verify controller is still active
        if (!Get.isRegistered<ChatUserCardController>(tag: 'chat_card_$userId')) {
          debugPrint('⚠️ Controller no longer registered, canceling stream');
          _userStreamSubscription?.cancel();
          return;
        }

        if (snapshot.exists && snapshot.data() != null) {
          try {
            final userData = snapshot.data()!;
            final updatedUser = ChatUser.fromJson(userData);

            // ADDED: Preload image when user data updates
            _preloadUserImage(updatedUser.image);
            // Force update reactive variable
            realtimeUserData.value = updatedUser;

            debugPrint('🔄 REAL-TIME UPDATE: ${updatedUser.name} | Online: ${updatedUser.isOnline} | Image: ${updatedUser.image.length > 20 ? updatedUser.image.substring(0, 20) + "..." : updatedUser.image}');

            // Force UI rebuild
            update(['user_data_$userId']);

          } catch (e) {
            debugPrint('❌ Error parsing user data: $e');
          }
        } else {
          debugPrint('⚠️ User document does not exist: $userId');
        }
      },
      onError: (error) {
        debugPrint('❌ User data stream error: $error');
      },
      cancelOnError: false,
    );
  }
// ADDED: Preload user images for faster display
  void _preloadUserImage(String imageUrl) {
    if (imageUrl.isEmpty || imageUrl == AppConstants.profileImg) {
      return; // Skip preloading for empty or default images
    }

    try {
      // Preload image into cache
      CachedNetworkImage.evictFromCache(imageUrl).then((_) {
        // Pre-cache the image
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
    // Cancel any existing subscriptions first
    _blockStatusSubscription?.cancel();
    _blockedByOtherSubscription?.cancel();

    // Listen to current user's blocked list
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
        final blockedUsers = userData?['blockedUsers'] as Map<String, dynamic>? ?? {};

        final wasBlocked = hasBlockedThem.value;
        hasBlockedThem.value = blockedUsers.containsKey(userId);

        debugPrint('📱 Block status updated - User $userId blocked by me: ${hasBlockedThem.value}');

        if (wasBlocked != hasBlockedThem.value) {
          update(['block_status_$userId']);
        }
      },
      onError: (error) {
        debugPrint('Error in block status stream: $error');
      },
      cancelOnError: false,
    );

    // Listen to other user's blocked list
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
        final blockedUsers = userData?['blockedUsers'] as Map<String, dynamic>? ?? {};

        final wasBlockedByOther = isBlockedByOther.value;
        isBlockedByOther.value = blockedUsers.containsKey(currentUID);

        debugPrint('👤 Blocked by other status updated - User $userId blocked me: ${isBlockedByOther.value}');

        if (wasBlockedByOther != isBlockedByOther.value) {
          update(['block_status_$userId']);
        }
      },
      onError: (error) {
        debugPrint('Error in blocked by other stream: $error');
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
  ChatUser get currentUserData => realtimeUserData.value;
}

class ChatUserCard extends StatelessWidget {
  final String currentUID;
  final ChatUser user;

  const ChatUserCard({
    super.key,
    required this.user,
    required this.currentUID,
  });

  @override
  Widget build(BuildContext context) {
    final String tag = 'chat_card_${user.id}';

    // Ensure controller exists
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
          onLongPress: () => _showBlockOptions(context, controller),
          child: _buildCardContent(controller),
        ),
      ),
    );
  }

  // ENHANCED: Separate widget for card content with targeted rebuilds
  Widget _buildCardContent(ChatUserCardController controller) {
    return GetBuilder<ChatUserCardController>(
      tag: 'chat_card_${user.id}',
      id: 'user_data_${user.id}', // Specific rebuild ID
      builder: (ctrl) {
        return Obx(() {
          final displayUser = ctrl.currentUserData;
          final isBlocked = ctrl.isCurrentlyBlocked;

          debugPrint('🎨 Building card UI for: ${displayUser.name} (${displayUser.id})');

          return ListTile(
            leading: _buildAvatar(isBlocked, displayUser),
            title: Text(
              displayUser.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: _buildSubtitle(ctrl.listController, ctrl.isBlockedByOther.value, displayUser),
            trailing: _buildTrailing(ctrl.listController, isBlocked),
          );
        });
      },
    );
  }

// Fixed _buildAvatar method with proper caching and loading states
  Widget _buildAvatar(bool isBlocked, ChatUser displayUser) {
    if (isBlocked) {
      return CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.person, color: Colors.grey, size: 30),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(25), // Make it circular
          child: CachedNetworkImage(
            imageUrl: displayUser.image.isNotEmpty
                ? displayUser.image
                : AppConstants.profileImg,
            height: 50, // radius * 2
            width: 50,  // radius * 2
            fit: BoxFit.cover,

            // Placeholder while loading
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

            // Error widget if image fails to load
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

            // Cache configuration for better performance
            cacheManager: DefaultCacheManager(),

            // Memory cache configuration
            memCacheHeight: 100, // Cache at 2x resolution for better quality
            memCacheWidth: 100,

            // Fade animation duration
            fadeInDuration: const Duration(milliseconds: 200),
            fadeOutDuration: const Duration(milliseconds: 200),
          ),
        ),

        // Online indicator
        if (!isBlocked && displayUser.isOnline)
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
  Widget _buildSubtitle(ChatListController controller, bool isBlocked, ChatUser displayUser) {
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
          displayUser.about, // Use real-time about text
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

  Widget _buildTrailing(ChatListController controller, bool isBlocked) {
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

    // Use real-time user data for navigation
    Get.to(() => ChattingView(
      user: controller.currentUserData,
      isBlocked: isBlocked,
      isBlockedByOther: isBlockedByOther,
    ))?.then((_) {
      chatController.setInsideChatStatus(false);
    });
  }

  void _showBlockOptions(BuildContext context, ChatUserCardController controller) async {
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
}