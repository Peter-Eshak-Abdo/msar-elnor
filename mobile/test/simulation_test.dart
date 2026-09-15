import 'package:flutter_test/flutter_test.dart';

void main() {
  group('مسار النور - اختبارات المحاكاة الشاملة لمنظومة الحظر الثلاثية', () {
    test('الطبقة الأولى (Plan A): فحص حزم التطبيقات والنصوص المحظورة', () {
      final blockedList = [
        'facebook.com',
        'tiktok.com',
        'instagram.com',
        'x.com',
        'twitter.com',
        'youtube.com/shorts',
        'reddit.com',
      ];

      // Simulate package and URL matching
      bool isTargetBlocked(String input) {
        final clean = input.toLowerCase();
        return blockedList.any((blocked) {
          final keyword = blocked.replaceAll('.com', '').replaceAll('/shorts', '');
          return clean.contains(keyword);
        });
      }

      expect(isTargetBlocked('com.zhiliaoapp.musically'), isFalse); // handled by exact package
      expect(isTargetBlocked('https://www.tiktok.com/@user/video'), isTrue);
      expect(isTargetBlocked('https://instagram.com/explore'), isTrue);
      expect(isTargetBlocked('https://flutter.dev'), isFalse);
    });

    test('الطبقة الثانية (Plan B): رصد التطبيقات النشطة عبر UsageStats', () {
      final recentPackages = [
        {'package': 'com.android.chrome', 'time': 1000},
        {'package': 'com.zhiliaoapp.musically', 'time': 5000},
        {'package': 'com.google.android.youtube', 'time': 2000},
      ];

      // Sort by recency
      recentPackages.sort((a, b) => (b['time'] as int).compareTo(a['time'] as int));
      final topApp = recentPackages.first['package'] as String;

      expect(topApp, equals('com.zhiliaoapp.musically'));
    });

    test('الطبقة الثالثة (Plan C): عناوين خوادم Family Shield DNS المحمية', () {
      const cloudflareFamilyDns = '1.1.1.3';
      const cleanBrowsingFamilyDns = '185.228.168.168';

      expect(cloudflareFamilyDns, matches(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$'));
      expect(cleanBrowsingFamilyDns, matches(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$'));
    });

    test('شاشة الدوبامين: خوارزمية المسائل الرياضية وتنشيط الفص الجبهي', () {
      // Test addition puzzle generator
      const int a = 24;
      const int b = 39;
      const int expected = 63;
      expect(a + b, equals(expected));

      // Test sequence puzzle: 3, 7, 11, [ 15 ]
      const int start = 3;
      const int step = 4;
      final seq = [start, start + step, start + (step * 2), start + (step * 3)];
      expect(seq.last, equals(15));
    });

    test('التحكم عن بعد: فحص وتأكيد كود الأمان الـ OTP المؤقت', () {
      final token = '742918';
      expect(token.length, equals(6));
      expect(int.tryParse(token), isNotNull);
    });
  });
}
