import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/blocker_channel.dart';

class SpiritualOverlayScreen extends StatefulWidget {
  final String interceptedTarget;
  final String fallbackUrl;

  const SpiritualOverlayScreen({
    super.key,
    required this.interceptedTarget,
    required this.fallbackUrl,
  });

  @override
  State<SpiritualOverlayScreen> createState() => _SpiritualOverlayScreenState();
}

class _SpiritualOverlayScreenState extends State<SpiritualOverlayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final int _currentTaskIndex = 0;
  bool _isTimerActive = false;
  int _secondsRemaining = 120; // 2-minute micro-task focus timer
  Timer? _timer;

  final List<Map<String, String>> _microTasks = [
    {
      'title': 'مشروع أبونا فلتاؤس: مهارات البيع والتفاوض الإقناعي',
      'desc': 'راجع الآن القاعدة الذهبية: «استمع لاحتياج العميل الحقيقي أولاً قبل عرض أي حل تقني». تدرب على صياغة جملة القيمة في 30 ثانية.',
      'tag': 'مهمة مبيعات (دقيقتين)',
      'points': '+50 نقطة نور',
    },
    {
      'title': 'تركيز روحي: مزمور وتأمل الحضور الإلهي',
      'desc': '«اِسْهَرُوا وَصَلُّوا لِئَلاَّ تَدْخُلُوا فِي تَجْرِبَةٍ». اغمض عينيك وصلّ صلاة يسوع بخشوع لمدة دقيقة لتهدئة ذهنك.',
      'tag': 'جرعة سلام روحي',
      'points': '+70 نقطة نور',
    },
    {
      'title': 'إنجاز تقني: مراجعة خطوة برمجية في مسار النور',
      'desc': 'فكر في ميزة برمجية واحدة تحتاج لإنهائها اليوم واكتب خطواتها في ورقة صغيرة أمامك للبدء بها فوراً.',
      'tag': 'تركيز هندسي',
      'points': '+40 نقطة نور',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  void _startTaskTimer() {
    setState(() {
      _isTimerActive = true;
      _secondsRemaining = 120;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        t.cancel();
        setState(() {
          _isTimerActive = false;
        });
        _showCompletedDialog();
      }
    });
  }

  void _showCompletedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: const Row(
            children: [
              Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
              SizedBox(width: 8),
              Text('أحسنت! انتصرت على التشتت', style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: const Text(
            'لقد حوّلت رغبة التشتت المؤقتة إلى إنجاز إيجابي حقيقي. عقلك الآن في حالة تركيز وسلام.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _closeOverlay();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: const Text('العودة للمتابعة والعمل', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _closeOverlay() {
    BlockerChannel.reportOverlayClosed();
    Navigator.of(context).pop();
  }

  Future<void> _openHymnLink() async {
    final uri = Uri.parse(widget.fallbackUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = _microTasks[_currentTaskIndex];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => _closeOverlay(),
        child: Scaffold(
          backgroundColor: const Color(0xFF070B14),
          body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.4),
                radius: 1.2,
                colors: [
                  Color(0xFF1E1B4B), // Deep spiritual indigo
                  Color(0xFF070B14), // Pure obsidian
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Intercept Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0x26EF4444),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x4DEF4444)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'تم حظر: ${widget.interceptedTarget} • مسار النور يحميك',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center Spiritual Cross & Scripture
                    Column(
                      children: [
                        ScaleTransition(
                          scale: Tween<double>(begin: 0.96, end: 1.05).animate(
                            CurvedAnimation(
                              parent: _pulseController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                                  blurRadius: 30,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.wb_sunny_rounded,
                                size: 46,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Text(
                          '«اِسْهَرُوا وَصَلُّوا لِئَلاَّ تَدْخُلُوا فِي تَجْرِبَةٍ»',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.amber.shade200,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'متى ٢٦ : ٤١',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),

                    // Micro-Task Dopamine Redirect Card (Stitch Designed)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0x4DF59E0B)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0x33F59E0B),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  task['tag']!,
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                task['points']!,
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            task['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            task['desc']!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),

                          // Timer Display if active
                          if (_isTimerActive) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.timer, color: Colors.blueAccent, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'الوقت المتبقي للمهمة: ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Actions & CTAs
                    Column(
                      children: [
                        // Primary CTA: Start Micro-Task (Dopamine positive)
                        ElevatedButton.icon(
                          onPressed: _isTimerActive ? _showCompletedDialog : _startTaskTimer,
                          icon: Icon(
                            _isTimerActive ? Icons.check_circle_rounded : Icons.bolt_rounded,
                            color: Colors.black,
                          ),
                          label: Text(
                            _isTimerActive ? 'أنهيت المهمة بنجاح!' : 'ابدأ الإنجاز الآن (دوبامين إيجابي)',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                            shadowColor: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Secondary: Fallback Spiritual Hymns
                        OutlinedButton.icon(
                          onPressed: _openHymnLink,
                          icon: const Icon(Icons.music_note_rounded, color: Colors.cyanAccent, size: 18),
                          label: const Text(
                            'الاستماع لتسبحة نصف الليل والألحان',
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                            side: const BorderSide(color: Color(0x4D06B6D4)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Dismiss to home
                        TextButton(
                          onPressed: _closeOverlay,
                          child: const Text(
                            'العودة لشاشة مسار النور والتركيز',
                            style: TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
