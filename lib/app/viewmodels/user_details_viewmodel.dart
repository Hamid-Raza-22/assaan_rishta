import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:assaan_rishta/app/core/routes/app_routes.dart';
import 'package:assaan_rishta/app/viewmodels/chat_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../core/export.dart';
import '../core/services/env_config_service.dart';
import '../domain/export.dart';
import '../utils/exports.dart';

class UserDetailsController extends GetxController {
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();
  final useCase = Get.find<UserManagementUseCase>();

  ChatViewModel? chatController;
  var profileDetails = ProfileDetails().obs;
  // Cached video preview data
  final Rx<Uint8List?> videoThumbnailData = Rx<Uint8List?>(null);
  final RxBool isVideoThumbLoading = false.obs;

  // Make receiverId reactive and handle it properly
  var receiverId = ''.obs;
  RxBool isLoading = true.obs; // Start with true to show loading immediately
  RxInt totalConnects = 0.obs;
  VideoPlayerController? videoController;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🚀 UserDetailsController onInit called');

    // Initialize the controller with arguments
    _initializeWithArguments();
  }

  // IMPORTANT: Override onReady to handle late initialization
  @override
  void onReady() {
    super.onReady();
    // Double-check if we have arguments after the widget is ready
    if (receiverId.value.isEmpty && Get.arguments != null) {
      _initializeWithArguments();
    }
  }

  void _initializeWithArguments() {
    // Get arguments and handle them properly
    _initializeReceiverId();

    // Only proceed if we have a valid receiver ID
    if (receiverId.value.isNotEmpty) {
      _initializeChatController();
      getProfileDetails();
    } else {
      debugPrint('⚠️ No receiver ID available, waiting for arguments...');
      // Listen for arguments changes
      ever(receiverId, (String id) {
        if (id.isNotEmpty) {
          debugPrint('📍 Receiver ID updated: $id');
          _initializeChatController();
          getProfileDetails();
        }
      });
    }
  }

  void _initializeReceiverId() {
    // Handle different argument types
    final args = Get.arguments;
    debugPrint('📋 Received arguments: $args (type: ${args.runtimeType})');

    String extractedId = '';

    if (args != null) {
      if (args is String) {
        extractedId = args;
      } else if (args is int) {
        extractedId = args.toString();
      } else if (args is Map) {
        extractedId = args['profileId']?.toString() ?? '';
      }
    }

    // Only update if we got a valid ID
    if (extractedId.isNotEmpty) {
      receiverId.value = extractedId;
      debugPrint('🎯 Receiver ID set to: ${receiverId.value}');
    } else {
      debugPrint('⚠️ No valid receiver ID found in arguments');
    }
  }

  Future<void> _initializeChatController() async {
    bool isLoggedIn = useCase.userManagementRepo.getUserLoggedInStatus();
    debugPrint('👤 User logged in: $isLoggedIn');

    if (isLoggedIn && Get.isRegistered<ChatViewModel>()) {
      chatController = Get.find<ChatViewModel>();
     await getConnects();
      debugPrint('💬 ChatController initialized');
    } else {
      debugPrint('💬 ChatController not initialized - user not logged in or service not available');
    }
  }

  // Method to reinitialize with new profile ID (called when route is replaced)
  void reinitializeWithNewProfile(String newProfileId) {
    debugPrint('🔄 Reinitializing controller with new profile: $newProfileId');

    // Clean up existing resources
    _cleanupResources();

    // Reset state
    receiverId.value = newProfileId;
    profileDetails.value = ProfileDetails();
    isLoading.value = true; // Show loading while fetching new profile

    // Reinitialize chat controller if needed
    _initializeChatController();

    // Reload data
    getProfileDetails();
  }

  void _cleanupResources() {
    // Dispose video controller if exists
    if (videoController != null) {
      videoController?.removeListener(() {});
      videoController?.pause();
      videoController?.dispose();
      videoController = null;
      debugPrint('🧹 Video controller cleaned up');
    }
  }

  getProfileDetails() async {
    if (receiverId.value.isEmpty) {
      debugPrint('❌ Cannot fetch profile - no receiver ID');
      isLoading.value = false;
      return;
    }

    debugPrint('📡 Fetching profile details for ID: ${receiverId.value}');
    isLoading.value = true;

    try {
      // Attempt to parse the receiverId to an integer
      int? userId = int.tryParse(receiverId.value);

      if (userId == null) {
        debugPrint('❌ Invalid receiver ID format: ${receiverId.value}');
        isLoading.value = false;
        // Only show error if we're in the foreground
        if (Get.context != null && !Get.isSnackbarOpen) {
          await Future.delayed(const Duration(milliseconds: 500));
          Get.snackbar(
            'Error',
            'Invalid profile ID format.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.redColor,
            colorText: AppColors.whiteColor,
            duration: const Duration(seconds: 2),
          );
        }
        return;
      }

      // Pass the parsed integer value
      final response = await useCase.getProfileDetails(uid: userId);

      response.fold(
            (error) {
          debugPrint('❌ Error fetching profile: $error');
          isLoading.value = false;
          // Only show error if we're in the foreground
          if (Get.context != null && !Get.isSnackbarOpen) {
            Future.delayed(const Duration(milliseconds: 500), () {
              Get.snackbar(
                'Error',
                'Failed to load profile details',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.redColor,
                colorText: AppColors.whiteColor,
                duration: const Duration(seconds: 2),
              );
            });
          }
        },
            (success) {
          debugPrint('✅ Profile loaded successfully: ${success.firstName} ${success.lastName}');
          debugPrint('🔵 Blur status from API: ${success.blurProfileImage} (User ID: ${success.userId})');
          profileDetails.value = success;
          isLoading.value = false;
          update(); // Force UI update
          // Prefetch video preview assets ASAP
          _prefetchVideoPreview();
        },
      );
    } catch (e) {
      debugPrint('💥 Exception in getProfileDetails: $e');
      isLoading.value = false;
      // Only show error if we're in the foreground
      if (Get.context != null && !Get.isSnackbarOpen) {
        await Future.delayed(const Duration(milliseconds: 500));
        Get.snackbar(
          'Error',
          'Something went wrong. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.redColor,
          colorText: AppColors.whiteColor,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  void _prefetchVideoPreview() {
    try {
      final String? videoUrl = profileDetails.value.tiktokLink;
      if (videoUrl == null || videoUrl.isEmpty) {
        videoThumbnailData.value = null;
        isVideoThumbLoading.value = false;
        update(['video_thumb']);
        return;
      }

      isVideoThumbLoading.value = true;
      update(['video_thumb']);

      // Kick off thumbnail fetch
      getVideoThumbnailData(videoUrl).then((bytes) async {
        videoThumbnailData.value = bytes;
        isVideoThumbLoading.value = false;
        update(['video_thumb']);

        // Warm up the video controller in background after thumbnail
        // Do not auto-play; keep it ready for quick start
        try {
          await Future.delayed(const Duration(milliseconds: 150));
          await initializeVideoPlayer(videoUrl);
        } catch (_) {}
      });
    } catch (e) {
      isVideoThumbLoading.value = false;
      update(['video_thumb']);
    }
  }

  getConnects() async {
    bool isLoggedIn = useCase.userManagementRepo.getUserLoggedInStatus();
    if (!isLoggedIn) {
      debugPrint('🔒 User not logged in - skipping connects fetch');
      return;
    }

    debugPrint('💰 Fetching connects...');

    final response = await systemConfigUseCases.getConnects();
    response.fold(
          (error) {
        debugPrint('❌ Error fetching connects: $error');
      },
          (success) {
        debugPrint('✅ Connects fetched: $success');
        totalConnects.value = int.parse(success);
        update();
      },
    );
  }

  void navigateToLogin() {
    Get.toNamed(AppRoutes.ACCOUNT_TYPE);
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        'Login Required',
        'Please login to send messages',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primaryColor,
        colorText: AppColors.whiteColor,
        duration: const Duration(seconds: 4),
      );
    }
  }

  sendMessageToOtherUser(context) async {
    bool isLoggedIn = useCase.userManagementRepo.getUserLoggedInStatus();
    if (!isLoggedIn) {
      navigateToLogin();
      return;
    }

    if (chatController == null) {
      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          'Error',
          'Chat service not available',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryColor,
          colorText: AppColors.whiteColor,
        );
      }
      return;
    }

    pauseVideoPlayback();

    String receiverIdStr = '${profileDetails.value.userId}';
    
    // Check if user is deactivated
    bool isDeactivated = await _checkIfUserIsDeactivated(receiverIdStr);
    if (isDeactivated) {
      if (!Get.isSnackbarOpen) {
        Get.snackbar(
          'User Unavailable',
          'This user has deactivated their profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.redColor,
          colorText: AppColors.whiteColor,
          duration: const Duration(seconds: 3),
        );
      }
      return;
    }
    String receiverName = '${profileDetails.value.firstName} ${profileDetails.value.lastName}';
    String receiverEmail = '${profileDetails.value.email}';
    String userImage = profileDetails.value.profileImage ?? AppConstants.profileImg;
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    debugPrint('💬 Sending message to: $receiverIdStr');

    ChatUser user = ChatUser(
      image: userImage,
      about: "Hey, I am using We Chat !!",
      name: receiverName,
      createdAt: time,
      lastActive: time,
      lastMessage: time,
      isOnline: false,
      isInside: false,
      isMobileOnline: false,
      isWebOnline: false,
      id: receiverIdStr,
      pushToken: "",
      email: receiverEmail);

    await chatController!.userExists(receiverIdStr).then((exist) async {
      if (exist) {
        ChatUser? chatUser = await chatController!.getUserById(receiverIdStr, userImage);
        if (chatUser != null) {
          await chatController!.addChatUser(chatUser.id);
          Get.toNamed(AppRoutes.CHATTING_VIEW, arguments: chatUser)!
              .then((onValue) async {
            await chatController!.setInsideChatStatus(false);
          });
        }
      } else {
        await chatController!.createUser(
          name: receiverName,
          id: receiverIdStr,
          email: receiverEmail,
          image: userImage,
          isOnline: false,
          isMobileOnline: false,
        ).then((onValue) async {
          await chatController!.addChatUser(user.id);
          Get.toNamed(AppRoutes.CHATTING_VIEW, arguments: user);
        });
      }
    });
  }

  // Video-related methods remain the same...
  String? extractTikTokVideoId(String url) {
    try {
      final RegExp regExp = RegExp(r'video/(\d+)');
      final match = regExp.firstMatch(url);
      return match?.group(1);
    } catch (e) {
      debugPrint("Error extracting TikTok video ID: $e");
      return null;
    }
  }

  Future<String?> getTikTokThumbnailFromOembed(String tiktokUrl) async {
    try {
      final oembedUrl = 'https://www.tiktok.com/oembed?url=${Uri.encodeComponent(tiktokUrl)}';
      final response = await http.get(Uri.parse(oembedUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['thumbnail_url'] as String?;
      }
    } catch (e) {
      debugPrint("Error getting TikTok thumbnail from oembed: $e");
    }
    return null;
  }

  Future<Uint8List?> getVideoThumbnailData(String videoUrl) async {
    try {
      if (_isTikTokUrl(videoUrl)) {
        final thumbnailUrl = await getTikTokThumbnailFromOembed(videoUrl);
        if (thumbnailUrl != null) {
          final response = await http.get(Uri.parse(thumbnailUrl));
          if (response.statusCode == 200) {
            return response.bodyBytes;
          }
        }
      }

      if (isDirectVideoUrl(videoUrl)) {
        return await VideoThumbnail.thumbnailData(
          video: videoUrl,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 200,
          quality: 75,
        );
      }
    } catch (e) {
      debugPrint("Error getting video thumbnail: $e");
    }
    return null;
  }

  bool _isTikTokUrl(String url) {
    return url.contains('tiktok.com') ||
        url.contains('vm.tiktok.com') ||
        url.contains('t.tiktok.com');
  }
// Add this method to extract the direct TikTok video URL
  Future<String?> extractTikTokVideoUrl(String tiktokUrl) async {
    try {
      // Using TikWM API (free service)
      final apiUrl = 'https://www.tikwm.com/api/?url=${Uri.encodeComponent(tiktokUrl)}';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 0 && data['data'] != null) {
          // Return the direct video URL without watermark (or use 'play' for watermarked version)
          return data['data']['wmplay'] ?? data['data']['play'];
        }
      }

      debugPrint("Failed to extract TikTok URL: ${response.body}");
    } catch (e) {
      debugPrint("Error extracting TikTok URL: $e");
    }
    return null;
  }
// Update your initializeVideoPlayer method
  Future<void> initializeVideoPlayer(String videoUrl) async {
    try {
      _cleanupResources(); // Clean up before initializing new player

      String? directUrl = videoUrl;

      // Check if it's a TikTok URL and extract the direct video URL
      if (_isTikTokUrl(videoUrl)) {
        debugPrint("🎬 Extracting TikTok video URL...");
        directUrl = await extractTikTokVideoUrl(videoUrl);

        if (directUrl == null) {
          debugPrint("❌ Failed to extract TikTok video URL");
          update(['video_player']);
          return;
        }

        debugPrint("✅ Extracted video URL: $directUrl");
      }

      videoController = VideoPlayerController.network(
        directUrl,
        httpHeaders: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
          'Referer': 'https://www.tiktok.com/', // Important for TikTok videos
        },
      );

      videoController!.addListener(() {
        if (videoController!.value.isInitialized) {
          update(['video_progress']);
        }
      });

      await videoController!.initialize();
      videoController!.setLooping(true);
      videoController!.setVolume(0.5);
      update(['video_player']);
    } catch (e) {
      debugPrint("Error initializing video player: $e");
      update(['video_player']);
    }
  }
  void toggleVideoPlayback() {
    if (videoController != null && videoController!.value.isInitialized) {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
      } else {
        videoController!.play();
      }
      update(['video_player']);
    }
  }

  void pauseVideoPlayback() {
    if (videoController != null &&
        videoController!.value.isInitialized &&
        videoController!.value.isPlaying) {
      videoController!.pause();
      update(['video_player']);
    }
  }

  void toggleVideoMute() {
    if (videoController != null && videoController!.value.isInitialized) {
      if (videoController!.value.volume > 0) {
        videoController!.setVolume(0);
      } else {
        videoController!.setVolume(0.5);
      }
      update(['video_player']);
    }
  }

  Future<Uint8List?> getVideoThumbnail(String videoUrl) async {
    try {
      debugPrint("Getting video thumbnail for: $videoUrl");
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
      );
      return thumbnail;
    } catch (e) {
      debugPrint("Error getting video thumbnail: $e");
      return null;
    }
  }

  bool isDirectVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.m4v', '.3gp'];
    final lowerUrl = url.toLowerCase();
    return videoExtensions.any((ext) => lowerUrl.contains(ext)) ||
        lowerUrl.contains('blob:') ||
        lowerUrl.contains('.m3u8');
  }

  /// Get gender-based placeholder image
  /// Returns male/female placeholder based on user's gender
  String getGenderBasedPlaceholder(String? gender) {
    if (gender == null || gender.isEmpty) {
      return AppAssets.imagePlaceholder;
    }
    
    // Check gender (case-insensitive)
    final genderLower = gender.toLowerCase();
    if (genderLower == 'male') {
      return AppAssets.malePlaceholder;
    } else if (genderLower == 'female') {
      return AppAssets.femalePlaceholder;
    } else {
      return AppAssets.imagePlaceholder;
    }
  }

  /// Check if user is deactivated in Firebase
  Future<bool> _checkIfUserIsDeactivated(String userId) async {
    try {
      // FIXED: Force fetch from server to get latest deactivation status
      // This ensures admin panel changes are reflected immediately
      final userDoc = await FirebaseFirestore.instance
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(userId)
          .get(const GetOptions(source: Source.server));
      
      if (userDoc.exists) {
        final data = userDoc.data();
        final isDeactivated = data?['is_deactivated'] ?? false;
        debugPrint('🔍 User $userId deactivation status: $isDeactivated');
        return isDeactivated;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error checking deactivation status: $e');
      return false;
    }
  }

  @override
  void onClose() {
    debugPrint('🔴 UserDetailsController onClose called');
    _cleanupResources();
    super.onClose();
  }
}