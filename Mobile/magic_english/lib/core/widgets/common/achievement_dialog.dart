import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/utils/backend_utils.dart';
import 'package:magic_enlish/data/models/progress/achievement.dart';

class AchievementDialog extends StatefulWidget {
  final Achievement achievement;

  const AchievementDialog({super.key, required this.achievement});

  // Bronze color from design
  static const Color bronzeColor = Color(0xFFCD7F32);
  static const Color primaryColor = Color(0xFF4A69FF);

  @override
  State<AchievementDialog> createState() => _AchievementDialogState();

  static void show(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => AchievementDialog(achievement: achievement),
    );
  }
}

class _AchievementDialogState extends State<AchievementDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _confettiController;
  late AnimationController _shineController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _shineAnimation;
  late Animation<double> _pulseAnimation;

  final List<ConfettiParticle> _confettiParticles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Scale animation for dialog entrance
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Rotate animation for badge
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.elasticOut),
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Shine animation for badge
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _shineAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    // Pulse animation for outer rings
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Generate confetti particles
    _generateConfetti();

    // Start animations
    _scaleController.forward();
    _rotateController.forward();
    _confettiController.forward();
  }

  void _generateConfetti() {
    final colors = [
      AchievementDialog.bronzeColor,
      AchievementDialog.primaryColor,
      Colors.amber,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.pink,
      Colors.purple,
    ];

    for (int i = 0; i < 50; i++) {
      _confettiParticles.add(
        ConfettiParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble() * -0.5 - 0.5,
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 10,
          velocityX: (_random.nextDouble() - 0.5) * 0.3,
          velocityY: _random.nextDouble() * 0.5 + 0.3,
          color: colors[_random.nextInt(colors.length)],
          size: _random.nextDouble() * 8 + 4,
          shape: _random.nextInt(3), // 0: circle, 1: square, 2: star
        ),
      );
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _confettiController.dispose();
    _shineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FA);
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark
        ? const Color(0xFFE5E7EB)
        : const Color(0xFF1F2937);
    final bodyColor = isDark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF4B5563);

    return Stack(
      children: [
        // Confetti Layer
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: ConfettiPainter(
                particles: _confettiParticles,
                progress: _confettiController.value,
              ),
            );
          },
        ),

        // Dialog
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 350),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AchievementDialog.bronzeColor.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badge Graphic with animations
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _rotateAnimation,
                      _pulseAnimation,
                      _shineAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: _buildBadgeGraphic(backgroundColor),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Sparkle text effect
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AchievementDialog.bronzeColor,
                        Colors.amber.shade300,
                        AchievementDialog.bronzeColor,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      '🎉 Congratulations! 🎉',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Headline
                  Text(
                    'New Badge Earned!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    widget.achievement.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: subtitleColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      widget.achievement.description.isNotEmpty
                          ? widget.achievement.description
                          : "You've taken your first step towards mastering new vocabulary. Great job!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: bodyColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Primary Button - Continue Learning
                  _buildAnimatedButton(
                    label: 'Continue Learning',
                    isPrimary: true,
                    isDark: isDark,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 12),

                  // Secondary Button - See my collection
                  _buildAnimatedButton(
                    label: 'See my collection',
                    isPrimary: false,
                    isDark: isDark,
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Navigate to achievements collection
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedButton({
    required String label,
    required bool isPrimary,
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: isPrimary ? 800 : 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPrimary
                ? AchievementDialog.primaryColor
                : AchievementDialog.primaryColor.withOpacity(
                    isDark ? 0.2 : 0.1,
                  ),
            foregroundColor: isPrimary
                ? Colors.white
                : AchievementDialog.primaryColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeGraphic(Color backgroundColor) {
    final hasCustomImage = widget.achievement.iconUrl.isNotEmpty;

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing circle
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AchievementDialog.bronzeColor.withOpacity(0.1),
                  ),
                ),
              );
            },
          ),
          // Inner pulsing circle
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.5,
                child: Container(
                  width: 145,
                  height: 145,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AchievementDialog.bronzeColor.withOpacity(0.2),
                  ),
                ),
              );
            },
          ),
          // Shine effect
          AnimatedBuilder(
            animation: _shineAnimation,
            builder: (context, child) {
              return ClipOval(
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AchievementDialog.bronzeColor.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(child: _buildAchievementIcon()),
                      // Shine overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment(_shineAnimation.value - 1, -1),
                              end: Alignment(_shineAnimation.value, 1),
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.4),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Badge number with bounce effect
          Positioned(
            bottom: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AchievementDialog.bronzeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: backgroundColor, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AchievementDialog.bronzeColor.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${widget.achievement.requiredValue}',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Star particles around badge
          ...List.generate(6, (index) {
            final angle = (index * 60) * pi / 180;
            return Positioned(
              left: 90 + cos(angle) * 100 - 8,
              top: 90 + sin(angle) * 100 - 8,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + index * 100),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: value,
                      child: Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber.withOpacity(0.8),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAchievementIcon() {
    // Check if we have a valid icon URL
    if (widget.achievement.iconUrl.isNotEmpty) {
      // Use BackendUtils to handle both relative and absolute URLs
      String fullUrl = BackendUtils.getFullUrl(
        widget.achievement.iconUrl.startsWith('http')
            ? widget.achievement.iconUrl
            : '/storage/achievement/${widget.achievement.iconUrl}',
      );

      return Image.network(
        fullUrl,
        width: 120,
        height: 120,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultIcon();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: 90,
            height: 90,
            child: Center(
              child: CircularProgressIndicator(
                color: AchievementDialog.bronzeColor,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }

    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    // Default icon based on metric type
    IconData iconData;
    switch (widget.achievement.metricType) {
      case 'vocab_added':
        iconData = Icons.auto_stories;
        break;
      case 'grammar_check':
        iconData = Icons.spellcheck;
        break;
      case 'learning_streak':
        iconData = Icons.local_fire_department;
        break;
      default:
        iconData = Icons.emoji_events;
    }

    return Icon(iconData, size: 80, color: AchievementDialog.bronzeColor);
  }
}

// Confetti Particle data class
class ConfettiParticle {
  double x;
  double y;
  double rotation;
  double rotationSpeed;
  double velocityX;
  double velocityY;
  Color color;
  double size;
  int shape;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.rotation,
    required this.rotationSpeed,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.shape,
  });
}

// Custom painter for confetti
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity((1 - progress) * 0.8)
        ..style = PaintingStyle.fill;

      // Calculate position based on progress
      final x = (particle.x + particle.velocityX * progress) * size.width;
      final y =
          (particle.y + particle.velocityY * progress * 2) * size.height +
          size.height * 0.2;

      if (y > size.height || y < 0) continue;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + particle.rotationSpeed * progress);

      switch (particle.shape) {
        case 0: // Circle
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case 1: // Square
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case 2: // Star shape (simple)
          final path = Path();
          for (int i = 0; i < 5; i++) {
            final angle = (i * 72 - 90) * pi / 180;
            final innerAngle = ((i * 72) + 36 - 90) * pi / 180;
            final outerRadius = particle.size / 2;
            final innerRadius = particle.size / 4;

            if (i == 0) {
              path.moveTo(cos(angle) * outerRadius, sin(angle) * outerRadius);
            } else {
              path.lineTo(cos(angle) * outerRadius, sin(angle) * outerRadius);
            }
            path.lineTo(
              cos(innerAngle) * innerRadius,
              sin(innerAngle) * innerRadius,
            );
          }
          path.close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
