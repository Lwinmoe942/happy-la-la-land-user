import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

/// Asks Play Store for a newer version as soon as the app opens.
/// Only works for builds installed from Google Play (not sideloaded APKs).
class PlayUpdate {
  static const packageId = 'com.happylalaland.user';
  static final _storeUri = Uri.parse(
    'https://play.google.com/store/apps/details?id=$packageId',
  );

  static Future<void> checkNow() async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }
      if (info.immediateUpdateAllowed) {
        final result = await InAppUpdate.performImmediateUpdate();
        if (result == AppUpdateResult.userDeniedUpdate) {
          await _openStore();
        }
        return;
      }
      if (info.flexibleUpdateAllowed) {
        final result = await InAppUpdate.startFlexibleUpdate();
        if (result == AppUpdateResult.success) {
          await InAppUpdate.completeFlexibleUpdate();
        } else if (result == AppUpdateResult.userDeniedUpdate) {
          await _openStore();
        }
        return;
      }
      await _openStore();
    } catch (_) {
      // Sideloaded / emulator / Play services missing — ignore.
    }
  }

  static Future<void> _openStore() async {
    try {
      await launchUrl(_storeUri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}
