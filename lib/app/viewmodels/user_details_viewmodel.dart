
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
  final chatController = Get.find<ChatViewModel>();
  var profileDetails = ProfileDetails().obs;
  final receiverId = Get.arguments;
  RxBool isLoading = false.obs;

  RxInt totalConnects = 0.obs;

  @override
  void onInit() {
    getConnects();
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

  sendMessageToOtherUser(context) async {
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

    await chatController.userExists(receiverId).then(
          (exist) async {
        if (exist) {
          ChatUser? chatUser = await chatController.getUserById(receiverId, userImage);
          if (chatUser != null) {
            await chatController.addChatUser(chatUser.id); // 👈 required!
            Get.toNamed(AppRoutes.CHATTING_VIEW, arguments: chatUser)!
                .then((onValue) async {
              await chatController.setInsideChatStatus(false);
            });
          }
        } else {
          await chatController.createUser(
            name: receiverName,
            id: receiverId,
            email: receiverEmail,
            image: userImage,
            isOnline: false,
            isMobileOnline: false,
          ).then((onValue) async {
            await chatController.addChatUser(user.id); // 👈 required!
            Get.toNamed(AppRoutes.CHATTING_VIEW, arguments: user);
          });
        }
      },
    );

  }
}
