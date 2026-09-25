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

  // 1. Accessibility Service
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

  // 2. Device Admin
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

  // 3. DNS Settings Button
  static Future<void> openDnsSettings() async {
    try {
      await _channel.invokeMethod('openDnsSettings');
    } on PlatformException catch (e) {
      debugPrint('Failed to open DNS settings: ${e.message}');
    }
  }

  // 4. Battery Optimization Whitelist (Anti-Kill 24/7)
  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool? ignoring = await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return ignoring ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } on PlatformException catch (e) {
      debugPrint('Failed to request battery optimization ignore: ${e.message}');
    }
  }

  // 5. UsageStats (Plan B Watchdog)
  static Future<bool> isUsageStatsGranted() async {
    try {
      final bool? granted = await _channel.invokeMethod<bool>('isUsageStatsGranted');
      return granted ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> requestUsageStatsPermission() async {
    try {
      await _channel.invokeMethod('requestUsageStatsPermission');
    } on PlatformException catch (e) {
      debugPrint('Failed to request usage stats permission: ${e.message}');
    }
  }

  // 6. Plan C: Local VPN
  static Future<bool> isVpnActive() async {
    try {
      final bool? active = await _channel.invokeMethod<bool>('isVpnActive');
      return active ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> startVpnService() async {
    try {
      await _channel.invokeMethod('startVpnService');
    } on PlatformException catch (e) {
      debugPrint('Failed to start VPN service: ${e.message}');
    }
  }

  static Future<void> stopVpnService() async {
    try {
      await _channel.invokeMethod('stopVpnService');
    } on PlatformException catch (e) {
      debugPrint('Failed to stop VPN service: ${e.message}');
    }
  }

  static Future<bool> isKillSwitchActive() async {
    try {
      final bool? active = await _channel.invokeMethod<bool>('isKillSwitchActive');
      return active ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> isSafeMode() async {
    try {
      final bool? safe = await _channel.invokeMethod<bool>('isSafeMode');
      return safe ?? false;
    } on PlatformException {
      return false;
    }
  }

  // 7. Foreground Protection Service
  static Future<bool> isForegroundServiceRunning() async {
    try {
      final bool? running = await _channel.invokeMethod<bool>('isForegroundServiceRunning');
      return running ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> startForegroundProtection() async {
    try {
      await _channel.invokeMethod('startForegroundProtection');
    } on PlatformException catch (e) {
      debugPrint('Failed to start foreground protection: ${e.message}');
    }
  }

  // 8. Overlay Permission
  static Future<bool> requestOverlayPermission() async {
    try {
      final bool? granted = await _channel.invokeMethod<bool>('requestOverlayPermission');
      return granted ?? false;
    } on PlatformException {
      return false;
    }
  }

  // 9. Rules Sync
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
