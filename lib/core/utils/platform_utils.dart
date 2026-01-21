import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Platform detection utilities
class PlatformUtils {
  /// Check if running on iOS
  static bool get isIOS => Platform.isIOS;
  
  /// Check if running on Android
  static bool get isAndroid => Platform.isAndroid;
  
  /// Check if should use Cupertino widgets (iOS/macOS)
  static bool get isCupertino => Platform.isIOS || Platform.isMacOS;
  
  /// Check if should use Material widgets (Android/Linux/Windows)
  static bool get isMaterial => Platform.isAndroid || Platform.isLinux || Platform.isWindows;
}

/// Haptic feedback utilities for iOS
class HapticUtils {
  /// Light impact haptic feedback (iOS only)
  static void lightImpact() {
    if (PlatformUtils.isIOS) {
      HapticFeedback.lightImpact();
    }
  }

  /// Medium impact haptic feedback (iOS only)
  static void mediumImpact() {
    if (PlatformUtils.isIOS) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Heavy impact haptic feedback (iOS only)
  static void heavyImpact() {
    if (PlatformUtils.isIOS) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Selection click haptic feedback
  /// iOS: Uses selectionClick
  /// Android: Uses vibrate
  static void selectionClick() {
    if (PlatformUtils.isIOS) {
      HapticFeedback.selectionClick();
    } else {
      HapticFeedback.vibrate();
    }
  }
}

/// Platform-specific animation curves and durations
class AdaptiveAnimations {
  /// Default animation curve for the platform
  /// iOS: easeInOut
  /// Android: easeInOutCubic
  static Curve get defaultCurve =>
      PlatformUtils.isIOS ? Curves.easeInOut : Curves.easeInOutCubic;

  /// Default animation duration for the platform
  /// iOS: 350ms
  /// Android: 300ms
  static Duration get defaultDuration => PlatformUtils.isIOS
      ? const Duration(milliseconds: 350)
      : const Duration(milliseconds: 300);

  /// Short animation duration
  /// iOS: 200ms
  /// Android: 150ms
  static Duration get shortDuration => PlatformUtils.isIOS
      ? const Duration(milliseconds: 200)
      : const Duration(milliseconds: 150);

  /// Long animation duration
  /// iOS: 500ms
  /// Android: 400ms
  static Duration get longDuration => PlatformUtils.isIOS
      ? const Duration(milliseconds: 500)
      : const Duration(milliseconds: 400);
}
