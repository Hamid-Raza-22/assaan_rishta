
// Updated user_details_viewmodel.dart
import 'package:assaan_rishta/app/core/routes/app_routes.dart';
import 'package:assaan_rishta/app/viewmodels/chat_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../core/export.dart';
// import '../core/services/firebase_service/firebase_service.dart';
import '../domain/export.dart';
import '../utils/exports.dart';

class UserDetailsController extends GetxController {
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();
  final useCase = Get.find<UserManagementUseCase>();

  // Make chatController nullable and initialize only if user is logged in
  ChatViewModel? chatController;

  var profileDetails = ProfileDetails().obs;
  final receiverId = Get.arguments;
  RxBool isLoading = false.obs;

  RxInt totalConnects = 0.obs;

  @override
  void onInit() {
    // Only initialize chat controller if user is logged in
    bool isLoggedIn = useCase.userManagementRepo.getUserLoggedInStatus();
    if (isLoggedIn && Get.isRegistered<ChatViewModel>()) {
      chatController = Get.find<ChatViewModel>();
      getConnects();
    }

    getProfileDetails();
    super.onInit();
  }

  getProfileDetails() async {
    isLoading.value = true;
    final response = await useCase.getProfileDetails(
      uid: receiverId,
    );
    return response.fold(
          (error) {
        isLoading.value = false;
      },
          (success) {
        profileDetails.value = success;
        isLoading.value = false;
        update();
      },
    );
  }

  getConnects() async {
    // Only get connects if user is logged in
    bool isLoggedIn = useCase.userManagementRepo.getUserLoggedInStatus();
    if (!isLoggedIn) return;

    isLoading = true.obs;
    final response = await systemConfigUseCases.getConnects();
    return response.fold(
          (error) {
        isLoading = false.obs;
      },
          (success) {
        isLoading = false.obs;
        totalConnects.value = int.parse(success);
        update();
      },
    );
  }

  // Method to navigate to login page
  void navigateToLogin() {
    // Navigate to your login page here
    // Replace AppRoutes.LOGIN with your actual login route
    Get.toNamed(AppRoutes.ACCOUNT_TYPE); // or whatever your login route is

    // Show a message to user
    Get.snackbar(
      'Login Required',
      'Please login to send messages',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primaryColor,
      colorText: AppColors.whiteColor,
      duration: const Duration(seconds: 4),
    );
  }

  sendMessageToOtherUser(context) async {
    // Check if user is logged in
    bool isLoggedIn = useCase.userManagementRepo.getUserLoggedInStatus();
    if (!isLoggedIn) {
      navigateToLogin();
      return;
    }

    // Check if chatController is available
    if (chatController == null) {
      Get.snackbar(
        'Error',
        'Chat service not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColor,
        colorText: AppColors.whiteColor,
      );
      return;
    }

    // AppUtils.onLoading(context);
    String receiverId = '${profileDetails.value.userId}';
    String receiverName = '${profileDetails.value.firstName} ${profileDetails.value.lastName}';
    String receiverEmail = '${profileDetails.value.email}';
    String userImage = profileDetails.value.profileImage ?? AppConstants.profileImg;
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    debugPrint('receiverIdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd: $receiverId');

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
      id: receiverId,
      pushToken: "",
      email: receiverEmail,
    );

    await chatController!.userExists(receiverId).then(
          (exist) async {
        if (exist) {
          ChatUser? chatUser = await chatController!.getUserById(receiverId, userImage);
          if (chatUser != null) {
            await chatController!.addChatUser(chatUser.id); // 👈 required!
            Get.toNamed(AppRoutes.CHATTING_VIEW, arguments: chatUser)!
                .then((onValue) async {
              await chatController!.setInsideChatStatus(false);
            });
          }
        } else {
          await chatController!.createUser(
            name: receiverName,
            id: receiverId,
            email: receiverEmail,
            image: userImage,
            isOnline: false,
            isMobileOnline: false,
          ).then((onValue) async {
            await chatController!.addChatUser(user.id); // 👈 required!
            Get.toNamed(AppRoutes.CHATTING_VIEW, arguments: user);
          });
        }
      },
    );
  }
}