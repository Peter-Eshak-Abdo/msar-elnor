import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 1. Random Theme Selector
  late int _themeIndex;
  final List<List<Color>> _themes = [
    [const Color(0xFF1E1B4B), const Color(0xFF0F172A), const Color(0xFFF59E0B)], // Cosmic Indigo & Gold
    [const Color(0xFF064E3B), const Color(0xFF022C22), const Color(0xFF10B981)], // Emerald Guard
    [const Color(0xFF4C0519), const Color(0xFF1E0209), const Color(0xFFFB7185)], // Deep Ruby Chastity
    [const Color(0xFF1E293B), const Color(0xFF090D16), const Color(0xFF38BDF8)], // Obsidian Celestial
  ];

  // 2. CBT Neuroscience Facts on Pornography & Dopamine (NoFap Style)
  late Map<String, String> _selectedCbtFact;
  final List<Map<String, String>> _cbtFacts = [
    {
      'title': 'وهم وفرط الإثارة (Hyper-Stimulation Illusion)',
      'body': 'المواد الإباحية لا تقدم شريكاً حقيقياً، بل تخدع المخ بفيض غير طبيعي من الدوبامين يُشبه المخدرات. عقلك يفرز دوبامين للبحث وليس للشبع، مما يتركك دائماً مستنزفاً وفارغاً.',
      'source': 'Dr. Gary Wilson - Your Brain On Porn',
    },
    {
      'title': 'تآكل الفص الجبهي (Hypofrontality)',
      'body': 'الاستسلام للإباحية يُعطل قشرة الفص الجبهي (Prefrontal Cortex) المسؤولة عن قوة الإرادة، التركيز، والتخطيط المستقبلي. بالتراجع الآن، أنت تُعيد تنشيط مركز قيادة عقلك وتنقذ ذكاءك البرمجي.',
      'source': 'Cambridge Neuroscience Journal',
    },
    {
      'title': 'تراكم بروتين دلتا فوس بي (Delta-FosB)',
      'body': 'كل استجابة للرغبة تبني روابط عصبية إدمانية عبر بروتين Delta-FosB. ولكن كل مرة تصمد فيها لمدة 3 دقائق فقط (Urge Surfing)، يذوب هذا البروتين وتبدأ خلايا مخك بالتشافي التلقائي (Neuroplasticity).',
      'source': 'Neurobiology of Addiction Research',
    },
    {
      'title': 'انخفاض الدوبامين الأساسي (Dopamine Baseline Crash)',
      'body': 'المتعة السريعة تعقبها بالضرورة كآبة وفقدان الشغف بالمذاكرة والعمل والمشاريع. الصمود يحفظ مخزون الدوبامين لمشروع تخرجك وبناء مستقبلك المالي.',
      'source': 'Dr. Andrew Huberman, Stanford Medicine',
    },
  ];

  // 3. Scriptures & Coptic Church Fathers on Chastity
  late Map<String, String> _selectedScripture;
  final List<Map<String, String>> _chastityScriptures = [
    {
      'verse': '«اُهْرُبُوا مِنَ الزِّنَى. كُلُّ خَطِيَّةٍ يَفْعَلُهَا الإِنْسَانُ هِيَ خَارِجَةٌ عَنِ الْجَسَدِ، لكِنَّ الَّذِي يَزْنِي يُخْطِئُ إِلَى جَسَدِهِ.»',
      'ref': '١ كورنثوس ٦ : ١٨',
      'meaning': 'الهروب الفوري بوعي هو خط الدفاع الوحيد.. جسدك هيكل للروح القدس.',
    },
    {
      'verse': '«كَيْفَ أَصْنَعُ هَذَا الشَّرَّ الْعَظِيمَ وَأُخْطِئُ إِلَى اللهِ؟»',
      'ref': 'التكوين ٣٩ : ٩ (يوسف الصديق)',
      'meaning': 'النقاء الحقيقي هو استحضار هيبة الله ورفض كسر قلبه المحب.',
    },
    {
      'verse': '«طُوبَى لأَنْقِيَاءِ الْقَلْبِ، لأَنَّهُمْ يُعَايِنُونَ اللهَ.»',
      'ref': 'متى ٥ : ٨',
      'meaning': 'نقاوة قلبك هي النافذة التي ترى بها عمل الله وحكمته في كل أمور حياتك.',
    },
    {
      'verse': '«إِنْ حَارَبَتكَ نَظْرَةٌ أَوْ فِكْرٌ رَدِيءٌ، فَاطْلُبِ اللهَ بِسُرْعَةٍ وَقُلْ: يَا رَبِّي يَسُوعُ أَعِنِّي، فَيَهْرُبَ عَنْكَ الْعَدُوُّ.»',
      'ref': 'القديس أنطونيوس الكبير كوكب البرية',
      'meaning': 'الصراخ السريع باسم يسوع المسيح يطرد أي ظلمة فوراً من النفس.',
    },
    {
      'verse': '«الشهوة إذا حوربت في بدايتها تلاشت، أما إذا تساهلت معها كبرت وصارت وحشاً يفترس طهارتك وسلامك.»',
      'ref': 'قداسة البابا شنوده الثالث',
      'meaning': 'اقطع الفكر في الثواني الأولى قبل أن يتحول إلى فعل يسرق بركتك وسلامك.',
    },
  ];

  // 4. Interactive Urge Surfing Box Breathing (4-4-4-4 for 30 Seconds)
  int _breathingSecondsLeft = 30;
  Timer? _breathingTimer;
  bool _isBreathingActive = false;
  bool _isBreathingCompleted = false;
  String _breathingPhaseText = 'استعد للتنفس';

  // 5. Dopamine Alternative Micro-Tasks (Programming & Side Hustles)
  int _selectedMicroTaskTab = 0; // 0 = Programming, 1 = Side Hustle
  bool _microTaskSolved = false;
  int _earnedLightPoints = 0;

  // 6. Audio Hymn State
  bool _isPlayingAudio = false;
  Timer? _audioTimer;

  @override
  void initState() {
    super.initState();
    final random = Random();

    _themeIndex = random.nextInt(_themes.length);
    _selectedCbtFact = _cbtFacts[random.nextInt(_cbtFacts.length)];
    _selectedScripture = _chastityScriptures[random.nextInt(_chastityScriptures.length)];

    // Setup animations
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Start 30-sec breathing automatically
    _startBreathingExercise();

    // Autoplay hymn audio snippet
    _startHymnPlayback();
  }

  void _startBreathingExercise() {
    _isBreathingActive = true;
    _breathingSecondsLeft = 30;
    _isBreathingCompleted = false;

    _breathingTimer?.cancel();
    _breathingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_breathingSecondsLeft > 0) {
          _breathingSecondsLeft--;
          // Calculate 4-phase cycle: 0-3 Inhale, 4-7 Hold, 8-11 Exhale, 12-15 Rest
          final cycleSec = (30 - _breathingSecondsLeft) % 16;
          if (cycleSec < 4) {
            _breathingPhaseText = 'شهيق عميق بهدوء (٤ ثوانٍ)';
          } else if (cycleSec < 8) {
            _breathingPhaseText = 'احبس النفس وركّز في سلامك (٤ ثوانٍ)';
          } else if (cycleSec < 12) {
            _breathingPhaseText = 'زفير بطيء يطرد كل اندفاع (٤ ثوانٍ)';
          } else {
            _breathingPhaseText = 'ثبات وسكون.. عقلك يستعيد السيطرة (٤ ثوانٍ)';
          }
        } else {
          _isBreathingActive = false;
          _isBreathingCompleted = true;
          _breathingPhaseText = 'أحسنت! كُسرت دائرة الدوبامين السلبية، والآن حان وقت البديل الإيجابي!';
          timer.cancel();
        }
      });
    });
  }

  Future<void> _startHymnPlayback() async {
    try {
      setState(() => _isPlayingAudio = true);

      const hymnAudioUrl = 'https://archive.org/download/FrMousaRoushdyHymns/ZnobyHmoul_snippet.mp3';
      
      await _audioPlayer.setSourceUrl(hymnAudioUrl).timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      await _audioPlayer.setVolume(0.85);
      await _audioPlayer.resume();

      _audioTimer = Timer(const Duration(seconds: 12), () {
        _stopHymnPlayback();
      });
    } catch (e) {
      debugPrint('Audio autoplay failed or device offline: $e');
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    }
  }

  void _stopHymnPlayback() {
    _audioTimer?.cancel();
    try {
      _audioPlayer.stop();
    } catch (_) {}
    if (mounted) {
      setState(() => _isPlayingAudio = false);
    }
  }

  void _closeOverlay() {
    _stopHymnPlayback();
    _breathingTimer?.cancel();
    BlockerChannel.reportOverlayClosed();
    Navigator.of(context).pop();
  }

  Future<void> _openFullHymn() async {
    _stopHymnPlayback();
    final uri = Uri.parse(widget.fallbackUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _stopHymnPlayback();
    _breathingTimer?.cancel();
    _audioPlayer.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = _themes[_themeIndex];
    final primaryAccent = currentTheme[2];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (_isBreathingCompleted || _microTaskSolved) {
            _closeOverlay();
          }
        },
        child: Scaffold(
          backgroundColor: currentTheme[1],
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 1.3,
                colors: [
                  currentTheme[0],
                  currentTheme[1],
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Top Intercept Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_rounded, color: primaryAccent, size: 16),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'تم اعتراض: ${widget.interceptedTarget} ${_earnedLightPoints > 0 ? "• +$_earnedLightPoints نقطة نور" : "• درع مسار النور يحفظك"}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Glowing Spiritual Sigil & Audio State
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ScaleTransition(
                          scale: Tween<double>(begin: 0.95, end: 1.08).animate(
                            CurvedAnimation(
                              parent: _pulseController,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [primaryAccent, primaryAccent.withValues(alpha: 0.6)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryAccent.withValues(alpha: 0.35),
                                  blurRadius: 32,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                size: 42,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Audio Playback Indicator
                    if (_isPlayingAudio) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.volume_up_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'ترنيمة «ذنوبي حمول بجرجرها» - أبونا موسى رشدي',
                            style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _stopHymnPlayback,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('إيقاف', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Chastity Scripture Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryAccent.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _selectedScripture['verse']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: primaryAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedScripture['ref']!,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Divider(color: Colors.white10, height: 20),
                          Text(
                            _selectedScripture['meaning']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CBT Neuroscience Message Card (Your Brain On Porn / NoFap)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.psychology_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'حقيقة علمية عصبية: ${_selectedCbtFact['title']}',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedCbtFact['body']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _selectedCbtFact['source']!,
                              style: const TextStyle(color: Colors.white38, fontSize: 10, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Interactive Urge Surfing Box Breathing (30 Seconds)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF064E3B).withValues(alpha: 0.7),
                            const Color(0xFF022C22).withValues(alpha: 0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isBreathingCompleted ? Colors.greenAccent : const Color(0xFF10B981).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.air_rounded, color: Colors.greenAccent, size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    'تمرين تنفس لكسر الاندفاع (Urge Surfing)',
                                    style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$_breathingSecondsLeft ثانية',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Animated Breathing Indicator
                          AnimatedContainer(
                            duration: const Duration(seconds: 4),
                            curve: Curves.easeInOut,
                            width: _isBreathingActive ? 85 : 70,
                            height: _isBreathingActive ? 85 : 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.greenAccent.withValues(alpha: 0.6),
                                  const Color(0xFF047857),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '$_breathingSecondsLeft',
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _breathingPhaseText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Alternative Dopamine & Instant Micro-Task Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _microTaskSolved ? Colors.greenAccent : const Color(0xFF6366F1).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.bolt_rounded, color: Colors.amber, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    _selectedMicroTaskTab == 0
                                        ? 'مهمة برمجية مصغرة (دوبامين إيجابي)'
                                        : 'مهمة عمل سريع (Side Hustle)',
                                    style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '+100 نقطة نور',
                                  style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Toggle Task Type
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _selectedMicroTaskTab = 0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _selectedMicroTaskTab == 0 ? const Color(0xFF4F46E5) : Colors.white10,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text('كود وبرمجة', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _selectedMicroTaskTab = 1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _selectedMicroTaskTab == 1 ? const Color(0xFF4F46E5) : Colors.white10,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text('عمل حر / AI Shorts', style: TextStyle(color: Colors.white, fontSize: 11)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (_selectedMicroTaskTab == 0) ...[
                            const Text(
                              '💡 التحدي: اكتب كود يفرز مصفوفة الأرقام [9, 2, 7, 4, 1] تصاعدياً في لغة Dart أو Python، أو صف كيف تعمل دالة QuickSort في جملة واحدة:',
                              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                            ),
                          ] else ...[
                            const Text(
                              '💼 اقتراح سريع: جهز فكرة فيديو YouTube Shorts مدته 40 ثانية بعنوان: «كيف يساعدك الذكاء الاصطناعي على بناء نظام عادات لا يُقهر»، أو اكتب أول سطر في Proposal عميل لبرمجة صفحة هبوط:',
                              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                            ),
                          ],
                          const SizedBox(height: 12),

                          if (!_microTaskSolved) ...[
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _microTaskSolved = true;
                                  _earnedLightPoints += 100;
                                });
                              },
                              icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.black, size: 16),
                              label: const Text(
                                'أتممت المهمة واستبدلت الرغبة بإنجاز (+100 نقطة)',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                minimumSize: const Size(double.infinity, 42),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.stars_rounded, color: Colors.greenAccent, size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'عاش يا بطل! عقلك اختار النمو والإنتاجية بدلاً من الاستنزاف (+100 نقطة نور).',
                                      style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    ElevatedButton.icon(
                      onPressed: _closeOverlay,
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.black),
                      label: const Text(
                        'العودة لمسار النور والتركيز',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _openFullHymn,
                      icon: const Icon(Icons.music_note_rounded, color: Colors.cyanAccent, size: 18),
                      label: const Text(
                        'الاستماع للترنيمة الكاملة / صلاة الأجبية',
                        style: TextStyle(color: Colors.cyanAccent, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 46),
                        side: const BorderSide(color: Color(0x4D06B6D4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
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
