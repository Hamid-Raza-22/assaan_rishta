import 'dart:io';

import 'package:assaan_rishta/app/core/bindings/app_bindings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/di/export.dart';
import 'app/core/routes/app_pages.dart';
import 'app/core/routes/app_routes.dart';

import 'app/domain/export.dart';
import 'app/utils/app_colors.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ///Initializing UseCase and Repo Dependencies <- Start ->
  final RepoDependencies repoDependencies = RepoDependencies();
  await repoDependencies.init().whenComplete(() {});
  await repoDependencies.initializeRepoDependencies();
  await initializeModelUseCasesDependencies();
  ///Initializing UseCase and Repo Dependencies <- End ->
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Notification service initialize


  runApp(const AsanRishtaApp());
}
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   debugPrint('🔥 Background message received: ${message.data}');
// }
// Update your _firebaseMessagingBackgroundHandler in main.dart:

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('🔥 Background message received: ${message.data}');

  // If it's a chat message, ensure sender is added to receiver's list
  if (message.data['type'] == 'chat') {
    final senderId = message.data['senderId'];
    final receiverId = message.data['receiverId'];

    if (senderId != null && senderId.isNotEmpty && receiverId != null) {
      try {
        debugPrint('📱 Background: Adding $senderId to $receiverId\'s chat list');

        // Add sender to receiver's my_users collection
        await FirebaseFirestore.instance
            .collection('Hamid_users')
            .doc(receiverId)
            .collection('my_users')
            .doc(senderId)
            .set({});

        debugPrint('✅ Background: Sender added to chat list');
      } catch (e) {
        debugPrint('❌ Background: Error adding sender: $e');
      }
    }
  }
}
class AsanRishtaApp extends StatelessWidget {
  const AsanRishtaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Asan Rishta',
      // theme: ThemeData(
      //   primarySwatch: Colors.red,
      //   fontFamily: 'Roboto',
      // ),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryColor,
            secondary: AppColors.secondaryColor,
          ),
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
      initialBinding: AppBindings(),
      initialRoute: AppRoutes.ACCOUNT_TYPE,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
