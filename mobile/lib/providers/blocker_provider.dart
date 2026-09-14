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
    ],
    startTime: '23:00',
    endTime: '07:00',
    fallbackUrl: 'https://www.youtube.com/watch?v=aripsalin-tasbeha',
    isActive: true,
  );

  bool _isAccessibilityActive = false;
  bool _isLoading = true;

  BlockerConfig get config => _config;
  bool get isAccessibilityActive => _isAccessibilityActive;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
    
    // Load persisted config from Hive if available
    final savedData = _box.get(configKey);
    if (savedData != null) {
      if (savedData is Map) {
        _config = BlockerConfig.fromMap(savedData);
      }
    } else {
      // Save initial defaults to Hive
      await _box.put(configKey, _config.toMap());
    }

    await checkPermissions();
    await BlockerChannel.syncRules(_config);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkPermissions() async {
    _isAccessibilityActive = await BlockerChannel.isAccessibilityEnabled();
    notifyListeners();
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
