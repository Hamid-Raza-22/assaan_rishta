// import 'dart:io';
//
// import 'package:asan_rishta/utils/app_colors.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
// import 'package:package_info_plus/package_info_plus.dart';
//
// const APP_STORE_URL =
//     'https://apps.apple.com/us/app/tap-tattoo/id6504286461?mt=8';
// const PLAY_STORE_URL =
//     'https://play.google.com/store/apps/details?id=com.asan.rishta.matrimonial.asan_rishta';
//
// versionCheck(context) async {
//   //Get Current installed version of app
//   final PackageInfo info = await PackageInfo.fromPlatform();
//   double currentVersion = double.parse(info.version.trim().replaceAll(".", ""));
//
//   //Get Latest version info from firebase config
//   final remoteConfig = FirebaseRemoteConfig.instance;
//   remoteConfig.setConfigSettings(
//     RemoteConfigSettings(
//       fetchTimeout: const Duration(minutes: 1),
//       minimumFetchInterval: const Duration(hours: 1),
//     ),
//   );
//   try {
//     // Using default duration to force fetching from remote server.
//     await remoteConfig.fetchAndActivate();
//     remoteConfig.getString('force_update_current_version');
//     double newVersion = double.parse(remoteConfig
//         .getString('force_update_current_version')
//         .trim()
//         .replaceAll(".", ""));
//     debugPrint('newVersion: $newVersion');
//     debugPrint('currentVersion: $currentVersion');
//     if (newVersion > currentVersion) {
//       _showVersionDialog(context);
//     }
//   } on Exception catch (exception) {
//     debugPrint(exception.toString());
//   } catch (exception) {
//     debugPrint(
//         'Unable to fetch remote config. Cached or default values will be '
//         'used');
//   }
// }
//
// _showVersionDialog(context) async {
//   await showDialog<String>(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       String title = "New Update Available";
//       String message =
//           "There is a newer version of app available please update it now.";
//       String btnLabel = "Update Now";
//       String btnLabelCancel = "Later";
//       return Platform.isIOS
//           ? CupertinoAlertDialog(
//               title: Text(title),
//               content: Text(message),
//               actions: <Widget>[
//                 TextButton(
//                   child: Text(
//                     btnLabel,
//                     style: const TextStyle(
//                       color: AppColors.blackColor,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   onPressed: () => launchURL(APP_STORE_URL),
//                 ),
//                 TextButton(
//                   child: Text(
//                     btnLabelCancel,
//                     style: const TextStyle(
//                       color: AppColors.blackColor,
//                     ),
//                   ),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             )
//           : AlertDialog(
//               backgroundColor: AppColors.whiteColor,
//               title: Text(title),
//               content: Text(message),
//               actions: <Widget>[
//                 TextButton(
//                   child: Text(btnLabel,
//                       style: const TextStyle(
//                         color: AppColors.blackColor,
//                         fontWeight: FontWeight.w600,
//                       )),
//                   onPressed: () => launchURL(PLAY_STORE_URL),
//                 ),
//                 TextButton(
//                   child: Text(
//                     btnLabelCancel,
//                     style: const TextStyle(
//                       color: AppColors.blackColor,
//                     ),
//                   ),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             );
//     },
//   );
// }
//
// Future<void> launchURL(String url) async {
//   await launchUrl(Uri.parse(url));
// }
