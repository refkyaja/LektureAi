import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color borderColor;
  final Color bgColor;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 15,
    this.borderColor = const Color(0x15FFFFFF),
    this.bgColor = const Color(0x0CFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Glowing circle surrounding top slide icons
class GlowingCircleIcon extends StatelessWidget {
  final IconData icon;
  final Color glowColor;

  const GlowingCircleIcon({
    super.key,
    required this.icon,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: glowColor.withOpacity(0.12),
        border: Border.all(color: glowColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: glowColor, size: 24),
    );
  }
}

// Slide 1: Welcome Slide Layout
class Slide1Welcome extends StatefulWidget {
  const Slide1Welcome({super.key});

  @override
  State<Slide1Welcome> createState() => _Slide1WelcomeState();
}

class _Slide1WelcomeState extends State<Slide1Welcome> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // 3D Illustration Centerpiece
        Expanded(
          flex: 5,
          child: Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Orbiting rings
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationController.value * 2 * math.pi,
                        child: CustomPaint(
                          size: const Size(260, 260),
                          painter: OrbitPainter(),
                        ),
                      );
                    },
                  ),
                  // Central 3D generated image
                  Image.asset(
                    'assets/onboarding/slide_1.png',
                    fit: BoxFit.contain,
                    width: 250,
                    height: 250,
                  ),
                  // Small floating icons
                  const Positioned(
                    top: 40,
                    right: 40,
                    child: FloatingIcon(
                      icon: Icons.lightbulb_outline_rounded,
                      color: Color(0xFFC77DFF),
                      delay: 0,
                    ),
                  ),
                  const Positioned(
                    bottom: 50,
                    left: 30,
                    child: FloatingIcon(
                      icon: Icons.auto_awesome,
                      color: Color(0xFF4DD0E1),
                      delay: 400,
                    ),
                  ),
                  const Positioned(
                    top: 150,
                    left: 20,
                    child: FloatingIcon(
                      icon: Icons.book_outlined,
                      color: Color(0xFF6C63FF),
                      delay: 800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Content Area
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Welcome to",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFB0ADFF),
                  ),
                ),
                Text(
                  "Lekture AI",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Your all-in-one AI study companion",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Capture, learn, and master any subject — smarter.",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF949CBE),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6C63FF).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Outer Orbit
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.45, paint);

    // Inner Orbit (slanted/dashed feel simulated by drawing arcs)
    final rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width * 0.3);
    canvas.drawArc(rect, 0, math.pi * 0.6, false, paint);
    canvas.drawArc(rect, math.pi, math.pi * 0.6, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FloatingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final int delay;

  const FloatingIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  State<FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<FloatingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x1F0A0E1A),
              border: Border.all(color: widget.color.withOpacity(0.25)),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.08),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(widget.icon, color: widget.color, size: 16),
          ),
        );
      },
    );
  }
}

// Slide 2: Voice to Text
class Slide2VoiceToText extends StatefulWidget {
  const Slide2VoiceToText({super.key});

  @override
  State<Slide2VoiceToText> createState() => _Slide2VoiceToTextState();
}

class _Slide2VoiceToTextState extends State<Slide2VoiceToText> with TickerProviderStateMixin {
  late AnimationController _waveformController;
  late AnimationController _pulseController;
  final List<double> _barHeights = [12, 28, 42, 20, 10, 32, 48, 22, 14, 30, 44, 26, 12, 38, 46, 20, 8];

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveformController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Top Icon
        const GlowingCircleIcon(
          icon: Icons.mic,
          glowColor: Color(0xFF4DD0E1),
        ),
        const SizedBox(height: 12),
        // Title & Subtitle
        Text(
          "Voice to Text",
          style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          "Speak, and let AI take notes for you.",
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF949CBE)),
        ),
        const SizedBox(height: 20),
        // Centerpiece Graph/Card
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Waveform and transcription GlassCard
              Positioned(
                top: 20,
                left: 24,
                right: 24,
                bottom: 120,
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timer row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "00:23",
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.equalizer, color: Colors.white30, size: 14),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Live Waveform visualizer
                        Center(
                          child: AnimatedBuilder(
                            animation: _waveformController,
                            builder: (context, child) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_barHeights.length, (index) {
                                  final baseHeight = _barHeights[index];
                                  final animVal = math.sin((_waveformController.value * 2 * math.pi) + (index * 0.4));
                                  final currentHeight = baseHeight * (0.6 + 0.4 * animVal);
                                  return Container(
                                    width: 3.5,
                                    height: currentHeight.clamp(4.0, 50.0),
                                    margin: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4DD0E1),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4DD0E1).withOpacity(0.3),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Extracted Text
                        Expanded(
                          child: SingleChildScrollView(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Photosynthesis ",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4DD0E1)),
                                  ),
                                  const TextSpan(
                                    text: "is the process by which green plants and some other organisms use sunlight to synthesize foods...",
                                  ),
                                  WidgetSpan(
                                    child: Container(
                                      width: 2,
                                      height: 14,
                                      margin: const EdgeInsets.only(left: 2),
                                      color: const Color(0xFF4DD0E1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Mic Button with Pulse ring
              Positioned(
                bottom: 20,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulse rings
                        ...List.generate(2, (index) {
                          final animation = CurvedAnimation(
                            parent: _pulseController,
                            curve: Interval(index * 0.4, 1.0, curve: Curves.easeOut),
                          );
                          return FadeTransition(
                            opacity: Tween<double>(begin: 0.5, end: 0.0).animate(animation),
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 1.0, end: 2.0).animate(animation),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0x334DD0E1),
                                ),
                              ),
                            ),
                          );
                        }),
                        // Main button
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4DD0E1), Color(0xFF00ACC1)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4DD0E1).withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.mic, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Listening badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006064).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF4DD0E1).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, size: 12, color: Color(0xFF4DD0E1)),
                          const SizedBox(width: 4),
                          Text(
                            "Listening...",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF4DD0E1),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Slide 3: Smart Study Tools
class Slide3SmartStudy extends StatelessWidget {
  const Slide3SmartStudy({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Top Icon
        const GlowingCircleIcon(
          icon: Icons.school_rounded,
          glowColor: Color(0xFFC77DFF),
        ),
        const SizedBox(height: 12),
        // Title & Subtitle
        Text(
          "Smart Study Tools",
          style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          "Generate quizzes & flashcards instantly.",
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF949CBE)),
        ),
        const SizedBox(height: 20),
        // Centerpiece Layout
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Flashcard peeking out
              Positioned(
                bottom: 50,
                left: 40,
                right: 40,
                child: Transform.rotate(
                  angle: -0.05,
                  child: Opacity(
                    opacity: 0.65,
                    child: GlassCard(
                      borderColor: const Color(0x10FFFFFF),
                      bgColor: const Color(0x06FFFFFF),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("ATP", style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFC77DFF).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                                  child: Text("3 / 10", style: GoogleFonts.inter(color: const Color(0xFFC77DFF), fontSize: 9)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "The energy currency of the cell.",
                              style: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Foreground Active Quiz Card
              Positioned(
                top: 10,
                left: 28,
                right: 28,
                bottom: 110,
                child: GlassCard(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.quiz, color: Color(0xFFC77DFF), size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  "Quiz",
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "What is the main function of mitochondria?",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Options
                            _buildQuizOption("A. Produce ribosomes", false),
                            _buildQuizOption("B. Generate energy", true),
                            _buildQuizOption("C. Store genetic material", false),
                            _buildQuizOption("D. Absorb sunlight", false),
                          ],
                        ),
                      ),
                      // Floating Gold Trophy Icon
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFD54F).withOpacity(0.15),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFFFD54F).withOpacity(0.1), blurRadius: 8),
                            ],
                          ),
                          child: const Icon(Icons.emoji_events, color: Color(0xFFFFD54F), size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizOption(String text, bool isCorrect) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0x223DD9AE) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCorrect ? const Color(0xFF3DD9AE) : Colors.white.withOpacity(0.1),
          width: isCorrect ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: isCorrect ? const Color(0xFF3DD9AE) : Colors.white60,
                fontSize: 11.5,
                fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (isCorrect)
            const Icon(Icons.check_circle, color: Color(0xFF3DD9AE), size: 14),
        ],
      ),
    );
  }
}

// Slide 4: Scan & Extract
class Slide4ScanExtract extends StatefulWidget {
  const Slide4ScanExtract({super.key});

  @override
  State<Slide4ScanExtract> createState() => _Slide4ScanExtractState();
}

class _Slide4ScanExtractState extends State<Slide4ScanExtract> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Top Icon
        const GlowingCircleIcon(
          icon: Icons.camera_alt_rounded,
          glowColor: Color(0xFFC77DFF),
        ),
        const SizedBox(height: 12),
        // Title & Subtitle
        Text(
          "Scan & Extract",
          style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          "Scan books or notes & extract text instantly.",
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF949CBE)),
        ),
        const SizedBox(height: 20),
        // Centerpiece Layout
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Illustration: Book with moving scanner grid line
              Positioned(
                top: 0,
                bottom: 100,
                left: 20,
                right: 20,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/onboarding/slide_4.png',
                      fit: BoxFit.contain,
                      width: 280,
                      height: 280,
                    ),
                    // Laser scan line animating up and down
                    AnimatedBuilder(
                      animation: _scanController,
                      builder: (context, child) {
                        final val = math.sin(_scanController.value * math.pi);
                        final topOffset = 40 + (160 * val);
                        return Positioned(
                          top: topOffset,
                          left: 40,
                          right: 40,
                          child: Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC77DFF),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFC77DFF).withOpacity(0.8),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Below: Extracted Text Box
              Positioned(
                bottom: 12,
                left: 24,
                right: 24,
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.text_fields_rounded, color: Color(0xFFC77DFF), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Photosynthesis is the process by which green plants and some organisms use sunlight to synthesize foods with the help of chlorophyll.",
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Slide 5: Ask AI Anything
class Slide5AskAi extends StatefulWidget {
  const Slide5AskAi({super.key});

  @override
  State<Slide5AskAi> createState() => _Slide5AskAiState();
}

class _Slide5AskAiState extends State<Slide5AskAi> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Top Icon
        const GlowingCircleIcon(
          icon: Icons.chat_bubble_rounded,
          glowColor: Color(0xFF4DD0E1),
        ),
        const SizedBox(height: 12),
        // Title & Subtitle
        Text(
          "Ask AI Anything",
          style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          "Your personal AI tutor, ready to help anytime.",
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF949CBE)),
        ),
        const SizedBox(height: 16),
        // Centerpiece Layout
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // User Chat Bubble (Top-Left)
              Positioned(
                top: 8,
                left: 20,
                child: GlassCard(
                  borderRadius: 14,
                  borderColor: const Color(0x1F6C63FF),
                  bgColor: const Color(0x126C63FF),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Text(
                      "Explain Newton's Second Law",
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              // Floating 3D Robot illustration
              Positioned(
                top: 40,
                bottom: 80,
                child: AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    final offsetVal = 10 * _floatController.value;
                    return Transform.translate(
                      offset: Offset(0, -offsetVal),
                      child: Image.asset(
                        'assets/onboarding/slide_5.png',
                        fit: BoxFit.contain,
                        width: 200,
                        height: 200,
                      ),
                    );
                  },
                ),
              ),
              // Robot Reply Chat Bubble (Bottom-Right)
              Positioned(
                bottom: 12,
                left: 24,
                right: 24,
                child: GlassCard(
                  borderRadius: 16,
                  borderColor: const Color(0x1F4DD0E1),
                  bgColor: const Color(0x124DD0E1),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Newton's Second Law states that force equals mass times acceleration. F = m·a.",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Example: Pushing a shopping cart...",
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 10.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
