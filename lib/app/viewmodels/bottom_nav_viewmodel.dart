import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/export.dart';

import '../core/services/firebase_service/export.dart';
import '../views/home/home_view.dart';
import '../views/profile/export.dart';
class BottomNavController extends GetxController {
  int selectedTab = 0;

  // final notificationService=NotificationServices();

  final List pages = [
    const HomeView(),
    // const VendorView(),
    // const ChatUserListingView(),
    // const FilterView(),
    const ProfileView(),
  ];
  final notificationService=NotificationServices();

  // get notificationService => null;

  changeTab(int index) {
    selectedTab = index;
    update();
  }

  notificationInit({required BuildContext context}) {
    notificationService.requestNotificationPermission();
    notificationService.forGroundMessage();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    notificationService.isTokenRefresh();
    notificationService.getDeviceToken().then((fcmToken) {
      _updateFcmToken(fcmToken);
      debugPrint('device token: $fcmToken');
    });
  }

  _updateFcmToken(String fcmToken) async {
    await FirebaseService.updateFcmToken(fcmToken:fcmToken);
  }
}
