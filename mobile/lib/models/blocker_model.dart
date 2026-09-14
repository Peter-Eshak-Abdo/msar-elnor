import 'dart:convert';

class BlockerConfig {
  final List<String> blockedUrls;
  final String startTime;
  final String endTime;
  final String fallbackUrl;
  final bool isActive;

  BlockerConfig({
    required this.blockedUrls,
    required this.startTime,
    required this.endTime,
    required this.fallbackUrl,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'blockedUrls': blockedUrls,
      'startTime': startTime,
      'endTime': endTime,
      'fallbackUrl': fallbackUrl,
      'isActive': isActive,
    };
  }

  factory BlockerConfig.fromMap(Map<dynamic, dynamic> map) {
    return BlockerConfig(
      blockedUrls: List<String>.from(map['blockedUrls'] ?? [
        'facebook.com',
        'tiktok.com',
        'instagram.com',
        'x.com',
        'twitter.com',
        'youtube.com/shorts'
      ]),
      startTime: map['startTime'] ?? '23:00',
      endTime: map['endTime'] ?? '07:00',
      fallbackUrl: map['fallbackUrl'] ?? 'https://www.youtube.com/watch?v=aripsalin-tasbeha',
      isActive: map['isActive'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory BlockerConfig.fromJson(String source) =>
      BlockerConfig.fromMap(json.decode(source));

  BlockerConfig copyWith({
    List<String>? blockedUrls,
    String? startTime,
    String? endTime,
    String? fallbackUrl,
    bool? isActive,
  }) {
    return BlockerConfig(
      blockedUrls: blockedUrls ?? this.blockedUrls,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      fallbackUrl: fallbackUrl ?? this.fallbackUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
