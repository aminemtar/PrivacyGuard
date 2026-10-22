import 'dart:io';

import 'package:flutter/services.dart';

/// Bridge to the optional Android-wide screen tint.
///
/// This does not control the camera and is unavailable on iOS. Android requires
/// the user to grant "Display over other apps" access in system settings.
class AndroidPrivacyOverlay {
  AndroidPrivacyOverlay._();

  static const MethodChannel _channel =
      MethodChannel('com.example.privacy_guard/privacy_overlay');

  static bool get isSupported => Platform.isAndroid;

  static Future<bool> hasPermission() async {
    if (!isSupported) return false;
    return await _channel.invokeMethod<bool>('hasOverlayPermission') ?? false;
  }

  /// Opens Android's system settings page; the user must grant access manually.
  static Future<void> requestPermission() async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('requestOverlayPermission');
  }

  static Future<bool> start() async {
    if (!isSupported) return false;
    return await _channel.invokeMethod<bool>('startOverlay') ?? false;
  }

  static Future<void> stop() async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('stopOverlay');
  }
}
