import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/blocker_model.dart';
import '../services/blocker_channel.dart';

class BlockerProvider with ChangeNotifier {
  static const String boxName = 'msar_elnor_box';
  static const String configKey = 'blocker_config';

  late Box _box;
  BlockerConfig _config = BlockerConfig(
    blockedUrls: [
      'facebook.com',
      'tiktok.com',
      'instagram.com',
      'x.com',
      'twitter.com',
      'youtube.com/shorts',
      'reddit.com',
      'snapchat.com',
    ],
    startTime: '23:00',
    endTime: '07:00',
    fallbackUrl: 'https://www.youtube.com/watch?v=aripsalin-tasbeha',
    isActive: true,
  );

  bool _isAccessibilityActive = false;
  bool _isDeviceAdminActive = false;
  bool _isBatteryOptIgnored = false;
  bool _isUsageStatsGranted = false;
  bool _isVpnActive = false;
  bool _isLoading = true;

  BlockerConfig get config => _config;
  bool get isAccessibilityActive => _isAccessibilityActive;
  bool get isDeviceAdminActive => _isDeviceAdminActive;
  bool get isBatteryOptIgnored => _isBatteryOptIgnored;
  bool get isUsageStatsGranted => _isUsageStatsGranted;
  bool get isVpnActive => _isVpnActive;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
    
    final savedData = _box.get(configKey);
    if (savedData != null) {
      if (savedData is Map) {
        _config = BlockerConfig.fromMap(savedData);
      }
    } else {
      await _box.put(configKey, _config.toMap());
    }

    await checkPermissions();
    await BlockerChannel.syncRules(_config);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkPermissions() async {
    _isAccessibilityActive = await BlockerChannel.isAccessibilityEnabled();
    _isDeviceAdminActive = await BlockerChannel.isDeviceAdminActive();
    _isBatteryOptIgnored = await BlockerChannel.isIgnoringBatteryOptimizations();
    _isUsageStatsGranted = await BlockerChannel.isUsageStatsGranted();
    _isVpnActive = await BlockerChannel.isVpnActive();
    notifyListeners();
  }

  Future<void> requestDeviceAdmin() async {
    await BlockerChannel.requestDeviceAdmin();
    await Future.delayed(const Duration(seconds: 1));
    await checkPermissions();
  }

  Future<void> openDnsSettings() async {
    await BlockerChannel.openDnsSettings();
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    await BlockerChannel.requestIgnoreBatteryOptimizations();
    await Future.delayed(const Duration(seconds: 1));
    await checkPermissions();
  }

  Future<void> requestUsageStats() async {
    await BlockerChannel.requestUsageStatsPermission();
    await Future.delayed(const Duration(seconds: 1));
    await checkPermissions();
  }

  Future<void> toggleVpn() async {
    if (_isVpnActive) {
      await BlockerChannel.stopVpnService();
    } else {
      await BlockerChannel.startVpnService();
    }
    await Future.delayed(const Duration(milliseconds: 800));
    await checkPermissions();
  }

  Future<void> toggleActive(bool val) async {
    _config = _config.copyWith(isActive: val);
    await _persistAndSync();
  }

  Future<void> updateTimes(String start, String end) async {
    _config = _config.copyWith(startTime: start, endTime: end);
    await _persistAndSync();
  }

  Future<void> updateFallbackUrl(String url) async {
    _config = _config.copyWith(fallbackUrl: url);
    await _persistAndSync();
  }

  Future<void> addBlockedUrl(String url) async {
    final clean = url.trim().toLowerCase().replaceAll(RegExp(r'^https?:\/\/'), '').replaceAll(RegExp(r'\/$'), '');
    if (clean.isEmpty || _config.blockedUrls.contains(clean)) return;

    final updated = List<String>.from(_config.blockedUrls)..add(clean);
    _config = _config.copyWith(blockedUrls: updated);
    await _persistAndSync();
  }

  Future<void> removeBlockedUrl(String url) async {
    final updated = List<String>.from(_config.blockedUrls)..remove(url);
    _config = _config.copyWith(blockedUrls: updated);
    await _persistAndSync();
  }

  Future<void> _persistAndSync() async {
    await _box.put(configKey, _config.toMap());
    await BlockerChannel.syncRules(_config);
    notifyListeners();
  }
}
