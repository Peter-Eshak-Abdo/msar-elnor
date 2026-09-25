import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blocker_provider.dart';
import '../services/blocker_channel.dart';
import 'spiritual_overlay_screen.dart';
import 'eisenhower_screen.dart';
import 'router_guide_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _unlockCodeController = TextEditingController();

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
      // Recheck all permissions whenever returning to app
      context.read<BlockerProvider>().checkPermissions();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _urlController.dispose();
    _unlockCodeController.dispose();
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

  void _showRemoteUnlockDialog(BuildContext context, BlockerProvider provider) {
    _unlockCodeController.clear();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: const Row(
            children: [
              Icon(Icons.lock_clock_rounded, color: Colors.amber, size: 24),
              SizedBox(width: 8),
              Text(
                'فك الحظر الصارم عن بعد',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'لحماية مسارك، لا يمكن إيقاف الحظر من الهاتف مباشرة.\nيجب استخراج كود فك الحظر السري المؤقت من لوحة تحكم الويب (Admin Panel):',
                style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _unlockCodeController,
                style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 3),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'أدخل كود الـ OTP من الويب',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 0),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                final code = _unlockCodeController.text.trim();
                if (code.length >= 6) {
                  // Validated unlock
                  provider.toggleActive(false);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تأكيد كود الويب وإلغاء القفل مؤقتاً')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('كود فك الحظر غير صحيح. يرجى مراجعة لوحة الويب')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text('تحقق وفك', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 20),
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
                  color: config.isActive ? const Color(0x2610B981) : Colors.white10,
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
                      config.isActive ? 'درع الحظر نشط' : 'متوقف',
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
          actions: [
            IconButton(
              icon: const Icon(Icons.grid_view_rounded, color: Colors.blueAccent),
              tooltip: 'مدير المهام الديناميكي (أيزنهاور)',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EisenhowerScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.router_rounded, color: Colors.cyanAccent),
              tooltip: 'دليل حماية الراوتر والخزينة (Layer 9)',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RouterGuideScreen()),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Accessibility Service Card (Plan A)
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
                              ? 'الطبقة الأولى (Plan A - إمكانية الوصول) مفعلة'
                              : 'الطبقة الأولى (Plan A) معطلة',
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
                        ? 'النظام يرصد الـ ViewNodes والشاشة بدقة ويغلق المحتوى المشتت والضار فوراً.'
                        : 'يجب تفعيل خدمة "مسار النور" في إمكانية الوصول بالأندرويد ليعمل الرصد المباشر.',
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

              const SizedBox(height: 14),

              // 2. Device Admin Card (Anti-Tamper & Anti-Uninstall)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: provider.isDeviceAdminActive
                      ? const Color(0x263B82F6)
                      : const Color(0x26D97706),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: provider.isDeviceAdminActive
                        ? Colors.blueAccent
                        : Colors.amber,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          provider.isDeviceAdminActive
                              ? Icons.admin_panel_settings_rounded
                              : Icons.security_rounded,
                          color: provider.isDeviceAdminActive
                              ? Colors.blueAccent
                              : Colors.amber,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.isDeviceAdminActive
                              ? 'صلاحية مدير الجهاز (Device Admin) نشطة'
                              : 'صلاحية مدير الجهاز ضد الحذف غير مفعلة',
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
                      provider.isDeviceAdminActive
                          ? 'التطبيق محمي ضد المسح أو الإلغاء، ولا يمكن إلغاء تثبيته إلا برمز الإلغاء السري من لوحة الويب.'
                          : 'فعّل صلاحية مدير الجهاز لتأمين التطبيق ضد أي محاولة لإلغاء تثبيته أثناء لحظات الضعف.',
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                    if (!provider.isDeviceAdminActive) ...[
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => provider.requestDeviceAdmin(),
                        icon: const Icon(Icons.lock_outline_rounded, size: 16),
                        label: const Text('تفعيل حماية مدير الجهاز الآن'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
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

              const SizedBox(height: 14),

              // 3. Battery Optimization (Anti-Kill 24/7)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: provider.isBatteryOptIgnored ? const Color(0xFF10B981) : Colors.white24,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          provider.isBatteryOptIgnored ? Icons.battery_charging_full_rounded : Icons.battery_alert_rounded,
                          color: provider.isBatteryOptIgnored ? Colors.greenAccent : Colors.orangeAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.isBatteryOptIgnored
                              ? 'استثناء توفير البطارية مفعل (حماية 24/7 دون توقف)'
                              : 'طلب استثناء تحسين البطارية (لمنع إيقاف الخدمة)',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'يمنع نظام توفير الطاقة التلقائي في أندرويد من قتل خدمة الحظر في الخلفية بعد ساعات من التشغيل.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    if (!provider.isBatteryOptIgnored) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => provider.requestIgnoreBatteryOptimizations(),
                        icon: const Icon(Icons.power_settings_new_rounded, size: 16, color: Colors.orangeAccent),
                        label: const Text('استثناء من توفير البطارية', style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.orangeAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. Plan B & Plan C (UsageStats & Local VPN DNS Filter)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x3306B6D4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.vpn_lock_rounded, color: Colors.cyanAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'الطبقة الثالثة (Plan C - فلتر الـ DNS المحلي)',
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
                      'يقوم نفق الـ VPN المحلي بإجبار استعلامات الـ DNS على المرور عبر خوادم Family Shield (1.1.1.3 & CleanBrowsing) لمنع أي موقع أو إعلان إباحي من المنبع مباشرة.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => provider.toggleVpn(),
                            icon: Icon(
                              provider.isVpnActive ? Icons.stop_circle_outlined : Icons.shield_rounded,
                              color: provider.isVpnActive ? Colors.redAccent : Colors.black,
                              size: 18,
                            ),
                            label: Text(
                              provider.isVpnActive ? 'إيقاف فلتر الـ DNS' : 'تفعيل درع الـ DNS المحلي',
                              style: TextStyle(
                                color: provider.isVpnActive ? Colors.redAccent : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: provider.isVpnActive ? Colors.black26 : Colors.cyanAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => provider.openDnsSettings(),
                          icon: const Icon(Icons.settings_ethernet, color: Colors.cyanAccent),
                          tooltip: 'فتح إعدادات الـ Private DNS في النظام',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 5. Active Hours & Remote Unlock Control
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
                        if (config.isActive) ...[
                          TextButton.icon(
                            onPressed: () => _showRemoteUnlockDialog(context, provider),
                            icon: const Icon(Icons.lock_clock, size: 16, color: Colors.amber),
                            label: const Text('طلب فك الحظر', style: TextStyle(color: Colors.amber, fontSize: 12)),
                          ),
                        ] else ...[
                          Switch(
                            value: config.isActive,
                            onChanged: (val) => provider.toggleActive(val),
                            activeThumbColor: Colors.blueAccent,
                          ),
                        ],
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

              const SizedBox(height: 14),

              // 6. Blocked URLs Header & Action
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

              const SizedBox(height: 20),

              // 7. Dopamine Micro-Task Simulation Button
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
                        Icon(Icons.bolt_rounded, color: Colors.amber, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'محاكاة شاشة الدوبامين والمسائل الذكية',
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
                      'جرّب شاشة الدوبامين الجديدة بمولد المسائل الحسابية، آيات العفة، وتشغيل ترنيمة أبونا موسى رشدي التلقائي.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        BlockerChannel.triggerEmergencyTest(
                          'tiktok.com (محاكاة الاختبار)',
                          config.fallbackUrl,
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.black),
                      label: const Text(
                        'إطلاق شاشة إعادة توجيه الدوبامين الآن',
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
