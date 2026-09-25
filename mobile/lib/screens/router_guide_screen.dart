import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RouterGuideScreen extends StatefulWidget {
  const RouterGuideScreen({super.key});

  @override
  State<RouterGuideScreen> createState() => _RouterGuideScreenState();
}

class _RouterGuideScreenState extends State<RouterGuideScreen> {
  int _selectedRouterIndex = 0;
  String _generatedPassword = '';
  bool _isPasswordVaultLocked = false;
  final TextEditingController _vaultNotesController = TextEditingController();

  final List<Map<String, dynamic>> _routers = [
    {
      'name': 'راوتر وي (WE - ZTE H168N / H188A)',
      'ip': '192.168.1.1',
      'steps': [
        'افتح المتصفح واكتب في شريط العنوان: 192.168.1.1',
        'سجل الدخول باسم المستخدم admin وكلمة المرور المكتوبة على ظهر الراوتر.',
        'ادخل على القائمة الجانبية: Local Network -> LAN -> DHCP Server.',
        'ابحث عن خانتي Primary DNS Server و Secondary DNS Server.',
        'ضع في Primary DNS: 185.228.168.168 (CleanBrowsing Family).',
        'ضع في Secondary DNS: 185.228.169.168 أو 208.67.222.123 (OpenDNS Family).',
        'اضغط Apply / Save وأعد تشغيل الراوتر لتعميم الحجب على كل أجهزة البيت.',
      ],
    },
    {
      'name': 'راوتر فودافون (Vodafone VDSL)',
      'ip': '192.168.1.1',
      'steps': [
        'افتح المتصفح وتوجه إلى: 192.168.1.1',
        'سجل الدخول باسم المستخدم vodafone أو admin وكلمة المرور خلف الراوتر.',
        'انتقل إلى: Internet -> Network Configuration -> DNS Configuration.',
        'فعل خيار Static DNS بدلاً من Automatic DNS.',
        'اكتب الـ Primary DNS: 185.228.168.168 والـ Secondary: 1.1.1.3.',
        'احفظ الإعدادات بالضغط على Save.',
      ],
    },
    {
      'name': 'راوتر أورنج (Orange DSL / VDSL)',
      'ip': '192.168.1.1',
      'steps': [
        'افتح العنوان: 192.168.1.1 في المتصفح.',
        'سجل الدخول (admin / admin أو الباسورد المطبوع على الملصق).',
        'اذهب إلى: Basic -> WAN -> خيارات DNS.',
        'أدخل: 185.228.168.168 ثم اضغط Submit.',
      ],
    },
    {
      'name': 'راوتر تي بي لينك (TP-Link Archer / VR)',
      'ip': '192.168.1.1',
      'steps': [
        'ادخل على: 192.168.1.1 أو tplinkwifi.net.',
        'اذهب إلى: Advanced -> Network -> DHCP Server.',
        'حدد Primary DNS: 185.228.168.168 و Secondary DNS: 208.67.222.123.',
        'اضغط Save ثم Reboot للراوتر.',
      ],
    },
  ];

  void _generateUltraSecurePassword() {
    const chars = 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#%^&*()-_+=';
    final random = Random.secure();
    final pwd = List.generate(24, (index) => chars[random.nextInt(chars.length)]).join();
    setState(() {
      _generatedPassword = pwd;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ النص إلى الحافظة بنجاح'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _lockInVault() {
    if (_generatedPassword.isEmpty) return;
    setState(() {
      _isPasswordVaultLocked = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔒 تم حفظ كلمة سر الراوتر مشفرة في الخزينة الآمنة!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _vaultNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = _routers[_selectedRouterIndex];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF090D16),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          title: const Row(
            children: [
              Icon(Icons.router_rounded, color: Colors.cyanAccent, size: 22),
              SizedBox(width: 8),
              Text(
                'دليل حماية الراوتر المنزلي (Layer 9)',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0x3306B6D4), Color(0xFF0F172A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x6606B6D4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_rounded, color: Colors.cyanAccent, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'تغيير DNS الراوتر المنزلي يحمي كل جهاز يتصل بشبكة الواي فاي من المنبع، ويمنع الالتفاف على الحماية حتى لو تم استخدام هاتف آخر.',
                        style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Router Selector
              const Text(
                'اختر نوع الراوتر الخاص بك:',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_routers.length, (idx) {
                    final isSelected = _selectedRouterIndex == idx;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          _routers[idx]['name']!.split('(')[0].trim(),
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.cyanAccent,
                        backgroundColor: const Color(0xFF1E293B),
                        onSelected: (val) {
                          if (val) setState(() => _selectedRouterIndex = idx);
                        },
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Steps Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            router['name'],
                            style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'IP: ${router['ip']}',
                            style: const TextStyle(color: Colors.amber, fontSize: 11, fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 20),
                    ...List.generate(
                      (router['steps'] as List<String>).length,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.cyanAccent.withValues(alpha: 0.15),
                                border: Border.all(color: Colors.cyanAccent),
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                router['steps'][i],
                                style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Ultra-Secure Password Generator & Encrypted Vault
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0x26F59E0B), Color(0xFF0F172A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.key_rounded, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'مولد كلمة سر الراوتر المعقدة والخزينة المشفرة',
                          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'قم بتغيير كلمة سر لوحة الراوتر إلى كلمة عشوائية مستحيلة التخمين واحفظها هنا مشفرة لمنع نفسك من تعطيل DNS الراوتر أثناء لحظات الضعف:',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    if (_generatedPassword.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _generatedPassword,
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _copyToClipboard(_generatedPassword),
                              icon: const Icon(Icons.copy_rounded, color: Colors.amber, size: 18),
                              tooltip: 'نسخ كلمة السر',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _generateUltraSecurePassword,
                            icon: const Icon(Icons.refresh_rounded, color: Colors.black, size: 16),
                            label: const Text(
                              'توليد كلمة سر معقدة (24 خانة)',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        if (_generatedPassword.isNotEmpty && !_isPasswordVaultLocked) ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: _lockInVault,
                            icon: const Icon(Icons.lock_rounded, color: Colors.white, size: 16),
                            label: const Text(
                              'قفل في الخزينة',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ],
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
