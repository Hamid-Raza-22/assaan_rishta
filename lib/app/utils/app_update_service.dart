import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'exports.dart';

const APP_STORE_URL =
    'https://apps.apple.com/us/app/tap-tattoo/id6504286461?mt=8';
const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.asan.rishta.matrimonial.asan_rishta';

versionCheck(context) async {
  try {
    // Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();

    // Parse version string properly (e.g., "1.2.6" -> 126)
    String currentVersionString = info.version.trim();
    double currentVersion = double.parse(currentVersionString.replaceAll(".", ""));

    debugPrint('📱 Current app version: $currentVersionString (parsed: $currentVersion)');

    // Get Latest version info from firebase config
    final remoteConfig = FirebaseRemoteConfig.instance;

    // Configure remote config settings
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: Duration.zero,
      ),
    );

    // Fetch and activate remote config
    bool fetchResult = await remoteConfig.fetchAndActivate();
    debugPrint('🔄 Fetch and activate result: $fetchResult');

    // Get all remote config keys to debug
    debugPrint('🔑 All Remote Config Keys: ${remoteConfig.getAll().keys.toList()}');

    // Get the force update version from remote config
    String remoteVersionString = remoteConfig.getString('force_update_current_version').trim();

    // Check if remote version string is empty
    if (remoteVersionString.isEmpty) {
      debugPrint('⚠️ Remote version string is empty');
      return;
    }

    double newVersion = double.parse(remoteVersionString.replaceAll(".", ""));

    debugPrint('🌐 Remote version: $remoteVersionString (parsed: $newVersion)');
    debugPrint('📊 Version comparison: current=$currentVersion, remote=$newVersion');

    // Show update dialog if remote version is greater than current version
    if (newVersion > currentVersion) {
      debugPrint('🔄 Update available! Showing update dialog...');
      await _showVersionDialog(context);
    } else {
      debugPrint('✅ App is up to date');
    }

  } on Exception catch (exception) {
    debugPrint('❌ Exception during version check: ${exception.toString()}');
  } catch (error) {
    debugPrint('❌ Error during version check: ${error.toString()}');
  }
}

_showVersionDialog(context) async {
  await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      String title = "New Update Available";
      String message =
          "There is a newer version of app available please update it now.";
      String btnLabel = "Update Now";
      String btnLabelCancel = "Later";

      return Platform.isIOS
          ? CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text(
              btnLabel,
              style: const TextStyle(
                color: AppColors.blackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => launchURL(APP_STORE_URL),
          ),
          TextButton(
            child: Text(
              btnLabelCancel,
              style: const TextStyle(
                color: AppColors.blackColor,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      )
          : AlertDialog(
        backgroundColor: AppColors.whiteColor,
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text(
              btnLabel,
              style: const TextStyle(
                color: AppColors.blackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => launchURL(PLAY_STORE_URL),
          ),
          TextButton(
            child: Text(
              btnLabelCancel,
              style: const TextStyle(
                color: AppColors.blackColor,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}

Future<void> launchURL(String url) async {
  await launchUrl(Uri.parse(url));
}