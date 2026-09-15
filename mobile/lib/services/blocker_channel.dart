import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/blocker_model.dart';

class BlockerChannel {
  static const MethodChannel _channel = MethodChannel('com.masarelnor.app/blocker');

  static final StreamController<Map<String, dynamic>> _triggerStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get onBlockerTriggered =>
      _triggerStreamController.stream;

  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onBlockerTriggered') {
        final arguments = Map<String, dynamic>.from(call.arguments ?? {});
        _triggerStreamController.add(arguments);
      }
    });
  }

  static Future<bool> isAccessibilityEnabled() async {
    try {
      final bool? enabled = await _channel.invokeMethod<bool>('isAccessibilityEnabled');
      return enabled ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (e) {
      debugPrint('Failed to open accessibility settings: ${e.message}');
    }
  }

  static Future<bool> isDeviceAdminActive() async {
    try {
      final bool? active = await _channel.invokeMethod<bool>('isDeviceAdminActive');
      return active ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> requestDeviceAdmin() async {
    try {
      await _channel.invokeMethod('requestDeviceAdmin');
    } on PlatformException catch (e) {
      debugPrint('Failed to request device admin: ${e.message}');
    }
  }

  static Future<void> openDnsSettings() async {
    try {
      await _channel.invokeMethod('openDnsSettings');
    } on PlatformException catch (e) {
      debugPrint('Failed to open DNS settings: ${e.message}');
    }
  }

  static Future<bool> requestOverlayPermission() async {
    try {
      final bool? granted = await _channel.invokeMethod<bool>('requestOverlayPermission');
      return granted ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> syncRules(BlockerConfig config) async {
    try {
      await _channel.invokeMethod('updateRules', config.toMap());
    } on PlatformException catch (e) {
      debugPrint('Failed to sync rules with native service: ${e.message}');
    }
  }

  static Future<void> reportOverlayClosed() async {
    try {
      await _channel.invokeMethod('reportOverlayClosed');
    } on PlatformException catch (e) {
      debugPrint('Failed to report overlay closed: ${e.message}');
    }
  }

  static Future<void> triggerEmergencyTest(String target, String fallbackUrl) async {
    try {
      await _channel.invokeMethod('triggerSpiritualEmergency', {
        'target': target,
        'fallbackUrl': fallbackUrl,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to trigger emergency test: ${e.message}');
    }
  }
}
