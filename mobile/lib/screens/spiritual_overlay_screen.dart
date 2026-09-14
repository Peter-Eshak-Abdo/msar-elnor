import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';

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
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _audioPlayer = AudioPlayer();
    _playSpiritualBell();
  }

  Future<void> _playSpiritualBell() async {
    try {
      // Audio chime indicator
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _openHymnLink() async {
    final uri = Uri.parse(widget.fallbackUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF070B14),
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.4),
              radius: 1.2,
              colors: [
                Color(0xFF1E1B4B), // Deep spiritual indigo
                Color(0xFF070B14), // Pure deep dark
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x1FFF5252),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x4DFF5252)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'تم رصد وحظر: ${widget.interceptedTarget}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center Spiritual Emblem & Message
                  Column(
                    children: [
                      // Animated Spiritual Light Halo
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.95, end: 1.08).animate(
                          CurvedAnimation(
                            parent: _pulseController,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x59F59E0B),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.wb_sunny_rounded,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'مسار النور يرافقك',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                        '«اسْهَرُوا وَصَلُّوا لِئَلاَّ تَدْخُلُوا فِي تَجْرِبَةٍ. أَمَّا الرُّوحُ فَنَشِيطٌ وَأَمَّا الْجَسَدُ فَضَعِيفٌ»',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.amber.shade200,
                          fontSize: 15,
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xCC0F172A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Text(
                          'تذكر هدفك ومسارك المقدس. لقد تم إيقاف هذا التطبيق المشتت لحماية وقتك وتركيزك. استغل هذه اللحظة في الصلاة والتسبيح.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom Action Buttons
                  Column(
                    children: [
                      // Launch Tasbeha / Hymns Button
                      ElevatedButton.icon(
                        onPressed: _openHymnLink,
                        icon: const Icon(Icons.music_note_rounded, color: Colors.black),
                        label: const Text(
                          'فتح تسبحة نصف الليل والألحان الآن',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                          shadowColor: const Color(0x66F59E0B),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Dismiss button to go home
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'العودة لشاشة مسار النور والتركيز',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
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
    );
  }
}
