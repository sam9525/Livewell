import 'package:flutter/material.dart';
import 'onboarding_constants.dart';

// Registry to track GlobalKeys for onboarding targets
class OnboardingTargetRegistry {
  static final Map<String, GlobalKey> _keys = {};

  // Get or create a GlobalKey for a target
  static GlobalKey getKey(String targetKey) {
    if (!_keys.containsKey(targetKey)) {
      _keys[targetKey] = GlobalKey();
    }
    return _keys[targetKey]!;
  }

  // Get the RenderBox for a target widget
  static RenderBox? getRenderBox(String targetKey) {
    final key = _keys[targetKey];
    if (key == null || key.currentContext == null) {
      return null;
    }
    return key.currentContext!.findRenderObject() as RenderBox?;
  }

  // Get the global position and size of a target widget
  static Rect? getTargetRect(String targetKey) {
    final renderBox = getRenderBox(targetKey);
    if (renderBox == null || !renderBox.hasSize) {
      return null;
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
  }

  // Scroll to make the target widget visible
  static Future<void> scrollToTarget(String targetKey) async {
    final key = _keys[targetKey];
    if (key == null || key.currentContext == null) {
      debugPrint(
        'OnboardingTargetRegistry: No widget found for key "$targetKey"',
      );
      return;
    }

    try {
      // Use Scrollable.ensureVisible to smoothly scroll to the widget
      await Scrollable.ensureVisible(
        key.currentContext!,
        duration: OnboardingConstants.scrollDuration,
        curve: OnboardingConstants.scrollCurve,
        alignment: OnboardingConstants.spotlightScrollAlignment,
      );
    } on FlutterError catch (e) {
      debugPrint(
        'OnboardingTargetRegistry: Scroll failed for "$targetKey": $e',
      );
    }
  }

  // Unregister a specific target key
  static void unregisterKey(String targetKey) {
    _keys.remove(targetKey);
    debugPrint('OnboardingTargetRegistry: Unregistered key "$targetKey"');
  }

  // Check if a target key is registered
  static bool isRegistered(String targetKey) {
    return _keys.containsKey(targetKey);
  }
}
