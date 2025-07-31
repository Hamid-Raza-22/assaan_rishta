// Optimized bottom_nav_view.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/export.dart';
import '../../utils/exports.dart';
import '../chat/chatting_view.dart';
import 'export.dart';

class BottomNavView extends StatefulWidget {
  final int index;

  const BottomNavView({
    super.key,
    this.index = 0,
  });

  @override
  State<BottomNavView> createState() => _BottomNavViewState();
}

class _BottomNavViewState extends State<BottomNavView> {
  bool _hasHandledNavigation = false;
  void _checkForPendingChatNavigation() {
    // Prevent multiple executions
    if (_hasHandledNavigation) return;

    // Check if coming from notification with chat user
    final args = Get.arguments;
    if (args != null && args is Map) {
      final openChat = args['openChat'] as bool?;
      final chatUser = args['chatUser'] as ChatUser?;

      if (openChat == true && chatUser != null) {
        _hasHandledNavigation = true;

        // Navigate to chat after a small delay
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.to(() => ChattingView(user: chatUser));
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    // Use Get.find if already exists, otherwise create new
    final BottomNavController controller = Get.isRegistered<BottomNavController>()
        ? Get.find<BottomNavController>()
        : Get.put(BottomNavController(), permanent: true);

    // Only update tab if different
    if (controller.selectedTab.value != widget.index) {
      controller.updateTab(widget.index);
    }

    // Initialize notifications only once
    if (!controller.isNotificationInitialized) {
      controller.notificationInit(context: context);
    }

    // Handle notification navigation after view is built
    if (!_hasHandledNavigation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForPendingChatNavigation();
      });
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldExit = await _showExitDialog(context, controller);
        if (shouldExit) {
          await controller.cleanUpBeforeExit();
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: Obx(() => IndexedStack(
          index: controller.selectedTab.value,
          children: controller.pages,
        )),
        bottomNavigationBar: _buildBottomNavBar(controller),
      ),
    );
  }

  Widget _buildBottomNavBar(BottomNavController controller) {
    return Obx(() => BottomNavigationBar(
      backgroundColor: AppColors.whiteColor,
      currentIndex: controller.selectedTab.value,
      onTap: controller.changeTab,
      selectedItemColor: AppColors.secondaryColor,
      unselectedItemColor: AppColors.greyColor.withValues(alpha: 0.5),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.poppins(
        color: AppColors.secondaryColor,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        color: AppColors.secondaryColor,
        fontWeight: FontWeight.w400,
        fontSize: 10,
      ),
      items: _buildNavItems(controller.selectedTab.value),
    ));
  }

  List<BottomNavigationBarItem> _buildNavItems(int selectedIndex) {
    final items = [
      {'icon': AppAssets.icHome, 'label': 'Home'},
      {'icon': AppAssets.icVendor, 'label': 'Vendors'},
      {'icon': AppAssets.icChat, 'label': 'Chats'},
      {'icon': AppAssets.icFilter, 'label': 'Filter'},
      {'icon': AppAssets.icProfile, 'label': 'Profile'},

    ];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = index == selectedIndex;

      return BottomNavigationBarItem(
        icon: ImageHelper(
          image: item['icon']!,
          imageType: ImageType.asset,
          height: 24,
          width: 24,
          color: isSelected ? AppColors.secondaryColor : null,
        ),
        label: item['label'],
      );
    }).toList();
  }

  Future<bool> _showExitDialog(BuildContext context, BottomNavController controller) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ) ?? false;
  }
}