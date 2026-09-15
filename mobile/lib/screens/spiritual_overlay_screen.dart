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

  // 2. Scriptures on Chastity and Fleeing Sexual Immorality
  late Map<String, String> _selectedScripture;
  final List<Map<String, String>> _chastityScriptures = [
    {
      'verse': '«اُهْرُبُوا مِنَ الزِّنَى. كُلُّ خَطِيَّةٍ يَفْعَلُهَا الإِنْسَانُ هِيَ خَارِجَةٌ عَنِ الْجَسَدِ، لكِنَّ الَّذِي يَزْنِي يُخْطِئُ إِلَى جَسَدِهِ.»',
      'ref': '١ كورنثوس ٦ : ١٨',
      'meaning': 'الهروب الفوري هو خط الدفاع الوحيد.. جسدك هيكل للروح القدس.',
    },
    {
      'verse': '«كَيْفَ أَصْنَعُ هَذَا الشَّرَّ الْعَظِيمَ وَأُخْطِئُ إِلَى اللهِ؟»',
      'ref': 'التكوين ٣٩ : ٩ (يوسف الصديق)',
      'meaning': 'النقاء الحقيقي هو استحضار هيبة الله ورفض كسر قلبه المحب.',
    },
    {
      'verse': '«عَهْدًا قَطَعْتُ لِعَيْنَيَّ، فَكَيْفَ أَتَطَلَّعُ فِي عَذْرَاءَ؟»',
      'ref': 'أيوب ٣١ : ١',
      'meaning': 'حراسة النظر هي صمام أمان القلب والنفس.',
    },
    {
      'verse': '«لأَنَّ هذِهِ هِيَ إِرَادَةُ اللهِ: قَدَاسَتُكُمْ. أَنْ تَمْتَنِعُوا عَنِ الزِّنَى، أَنْ يَعْرِفَ كُلُّ وَاحِدٍ أَنْ يَقْتَنِيَ إِنَاءَهُ بِقَدَاسَةٍ وَكَرَامَةٍ.»',
      'ref': '١ تسالونيكي ٤ : ٣ - ٤',
      'meaning': 'كرامة نفسك وجسدك أغلى من لحظة متعة مسروقة تزول في ثوانٍ.',
    },
    {
      'verse': '«فَوْقَ كُلِّ تَحَفُّظٍ احْفَظْ قَلْبَكَ، لأَنَّ مِنْهُ مَخَارِجَ الْحَيَاةِ.»',
      'ref': 'الأمثال ٤ : ٢٣',
      'meaning': 'نقاوة أفكارك تحدد كل مسار حياتك وسلامك الداخلي.',
    },
    {
      'verse': '«لَمْ تُصِبْكُمْ تَجْرِبَةٌ إِلاَّ بَشَرِيَّةٌ. وَلكِنَّ اللهَ أَمِينٌ، الَّذِي لاَ يَدَعُكُمْ تُجَرَّبُونَ فَوْقَ مَا تَسْتَطِيعُونَ، بَلْ سَيَجْعَلُ مَعَ التَّجْرِبَةِ أَيْضًا الْمَنْفَذَ.»',
      'ref': '١ كورنثوس ١٠ : ١٣',
      'meaning': 'المنفذ موجود الآن أمامك.. اختر النور وتراجع بوعي.',
    },
  ];

  // 3. Random Math & IQ Puzzle Generator (Prefrontal Cortex Activation)
  late String _mathQuestion;
  late int _mathAnswer;
  final TextEditingController _answerController = TextEditingController();
  bool _isAnswerCorrect = false;
  String? _mathFeedback;

  // 4. Audio Hymn State
  bool _isPlayingAudio = false;
  Timer? _audioTimer;

  @override
  void initState() {
    super.initState();
    final random = Random();

    // Select random theme
    _themeIndex = random.nextInt(_themes.length);

    // Select random scripture
    _selectedScripture = _chastityScriptures[random.nextInt(_chastityScriptures.length)];

    // Generate random IQ/Math puzzle
    _generateRandomPuzzle(random);

    // Setup animations
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Autoplay hymn audio for 12-15 seconds
    _startHymnPlayback();
  }

  void _generateRandomPuzzle(Random random) {
    final puzzleType = random.nextInt(3);
    if (puzzleType == 0) {
      // Two-digit addition
      final a = 18 + random.nextInt(40);
      final b = 23 + random.nextInt(50);
      _mathQuestion = '$a + $b = ؟';
      _mathAnswer = a + b;
    } else if (puzzleType == 1) {
      // Multiplication
      final a = 6 + random.nextInt(9);
      final b = 7 + random.nextInt(8);
      _mathQuestion = '$a × $b = ؟';
      _mathAnswer = a * b;
    } else {
      // Sequence pattern (e.g. 4, 8, 16, ? or 5, 12, 19, ?)
      final start = 3 + random.nextInt(5);
      final step = 4 + random.nextInt(6);
      final seq1 = start;
      final seq2 = start + step;
      final seq3 = start + (step * 2);
      final seq4 = start + (step * 3);
      _mathQuestion = '$seq1 ، $seq2 ، $seq3 ، [ ؟ ]';
      _mathAnswer = seq4;
    }
  }

  Future<void> _startHymnPlayback() async {
    try {
      setState(() => _isPlayingAudio = true);

      // Stream / Hymn URL: Fr. Mousa Roushdy - Znoby Hmoul
      // Audio stream or online resource with fail-safe error handling
      const hymnAudioUrl = 'https://archive.org/download/FrMousaRoushdyHymns/ZnobyHmoul_snippet.mp3';
      
      await _audioPlayer.setSourceUrl(hymnAudioUrl).timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      await _audioPlayer.setVolume(0.85);
      await _audioPlayer.resume();

      // Automatically stop after exactly 12 seconds
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

  void _verifyAnswer() {
    final text = _answerController.text.trim();
    final parsed = int.tryParse(text);
    if (parsed == _mathAnswer) {
      setState(() {
        _isAnswerCorrect = true;
        _mathFeedback = 'رائع! عقلك المنطقي استعاد سيطرته الكاملة (+100 نقطة نور).';
      });
      _stopHymnPlayback();
    } else {
      setState(() {
        _mathFeedback = 'إجابة غير صحيحة، ركز جيداً وحاول ثانية!';
      });
    }
  }

  void _closeOverlay() {
    _stopHymnPlayback();
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
    _audioPlayer.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _answerController.dispose();
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
          if (_isAnswerCorrect) {
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
                              'تم اعتراض: ${widget.interceptedTarget} • درع مسار النور يحفظك',
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

                    // Dopamine IQ & Math Brain Redirect
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isAnswerCorrect ? const Color(0xFF10B981) : Colors.amber.withValues(alpha: 0.3),
                        ),
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
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'تنشيط الفص الجبهي (Prefrontal Cortex)',
                                  style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Icon(Icons.psychology_rounded, color: Colors.amber, size: 20),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'حل هذه المسألة الذهنية لكسر دائرة الدوبامين السلبية فوراً:',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              _mathQuestion,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          if (!_isAnswerCorrect) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _answerController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      hintText: 'اكتب الناتج هنا',
                                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                                      filled: true,
                                      fillColor: Colors.white.withValues(alpha: 0.08),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onSubmitted: (_) => _verifyAnswer(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _verifyAnswer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryAccent,
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('تحقق', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],

                          if (_mathFeedback != null) ...[
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                _mathFeedback!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _isAnswerCorrect ? const Color(0xFF10B981) : Colors.redAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    if (_isAnswerCorrect) ...[
                      ElevatedButton.icon(
                        onPressed: _closeOverlay,
                        icon: const Icon(Icons.check_circle_rounded, color: Colors.black),
                        label: const Text(
                          'تم تأكيد اليقظة • العودة لمسار النور',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ] else ...[
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
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _closeOverlay,
                        child: const Text(
                          'تجاوز والعودة للشاشة الرئيسية',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ),
                    ],
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
