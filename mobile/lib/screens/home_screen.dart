import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blocker_provider.dart';
import '../services/blocker_channel.dart';
import 'spiritual_overlay_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen to background blocker triggers from native Kotlin
    BlockerChannel.onBlockerTriggered.listen((event) {
      if (!mounted) return;
      final target = event['target'] ?? 'موقع محظور';
      final fallback = event['fallbackUrl'] ?? 'https://www.youtube.com/watch?v=aripsalin-tasbeha';

      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => SpiritualOverlayScreen(
            interceptedTarget: target,
            fallbackUrl: fallback,
          ),
        ),
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recheck accessibility permission whenever returning to app
      context.read<BlockerProvider>().checkPermissions();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _urlController.dispose();
    super.dispose();
  }

  void _showAddUrlDialog(BuildContext context, BlockerProvider provider) {
    _urlController.clear();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: const Text(
            'إضافة موقع أو تطبيق للحظر',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: TextField(
            controller: _urlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'مثال: tiktok.com, x.com',
              hintStyle: const TextStyle(color: Colors.white38),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white12),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_urlController.text.trim().isNotEmpty) {
                  provider.addBlockedUrl(_urlController.text.trim());
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('إضافة', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BlockerProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF090D16),
        body: Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    final config = provider.config;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF090D16),
        appBar: AppBar(
          backgroundColor: const Color(0xFF090D16),
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.indigoAccent],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'ن',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'مسار النور',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: config.isActive
                      ? const Color(0x2610B981)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: config.isActive ? const Color(0xFF10B981) : Colors.white24,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: config.isActive ? Colors.greenAccent : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      config.isActive ? 'الحظر نشط' : 'متوقف',
                      style: TextStyle(
                        color: config.isActive ? Colors.greenAccent : Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accessibility Service Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: provider.isAccessibilityActive
                      ? const Color(0x33064E3B)
                      : const Color(0x337F1D1D),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: provider.isAccessibilityActive
                        ? const Color(0xFF10B981)
                        : Colors.redAccent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          provider.isAccessibilityActive
                              ? Icons.verified_rounded
                              : Icons.warning_amber_rounded,
                          color: provider.isAccessibilityActive
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.isAccessibilityActive
                              ? 'صلاحية الحظر الصارم (Accessibility) مفعلة'
                              : 'صلاحية الحظر الصارم (Accessibility) معطلة',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.isAccessibilityActive
                        ? 'النظام يراقب الشاشة بدقة ويمنع المشتتات فور فتحها مع إطلاق شاشة التسابيح.'
                        : 'يجب تفعيل خدمة "مسار النور" في إمكانية الوصول بالأندرويد ليعمل الإغلاق القسري الصارم.',
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                    if (!provider.isAccessibilityActive) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => BlockerChannel.openAccessibilitySettings(),
                        icon: const Icon(Icons.settings, size: 16),
                        label: const Text('تفعيل إمكانية الوصول الآن'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Active Hours & Toggle Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.timer_outlined, color: Colors.blueAccent, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'أوقات الحظر النشطة',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: config.isActive,
                          onChanged: (val) => provider.toggleActive(val),
                          activeThumbColor: Colors.blueAccent,
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('بداية الحظر', style: TextStyle(color: Colors.white54, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(
                              config.startTime,
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_back_rounded, color: Colors.white24, size: 18),
                        Column(
                          children: [
                            const Text('نهاية الحظر', style: TextStyle(color: Colors.white54, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(
                              config.endTime,
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Blocked URLs Header & Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'قائمة المحظورات (${config.blockedUrls.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAddUrlDialog(context, provider),
                    icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                    tooltip: 'إضافة موقع محظور',
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // URLs Wrap
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: config.blockedUrls.map((url) {
                  return Chip(
                    backgroundColor: const Color(0xFF1E293B),
                    side: const BorderSide(color: Color(0x4DF87171)),
                    label: Text(
                      url,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                    onDeleted: () => provider.removeBlockedUrl(url),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Emergency Simulation Test Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x991E1B4B),
                      Color(0xFF0F172A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x4D6366F1)),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.science_outlined, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'محاكاة واختبار رصد الحظر',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'جرّب ظهور شاشة الألحان والتسابيح الروحية الطارئة كما تظهر عند محاولة فتح تطبيق محظور.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        BlockerChannel.triggerEmergencyTest(
                          'tiktok.com (محاكاة)',
                          config.fallbackUrl,
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.black),
                      label: const Text(
                        'إطلاق شاشة التسابيح والألحان التجريبية',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
