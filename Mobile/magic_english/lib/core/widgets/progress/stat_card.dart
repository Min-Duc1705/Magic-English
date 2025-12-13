import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatCard extends StatefulWidget {
  final dynamic icon;
  final Color iconColor;
  final String title1;
  final String title2;
  final String value;
  final bool animated;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title1,
    required this.title2,
    required this.value,
    this.animated = false,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.4,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.orange, end: Colors.red.shade700),
        weight: 33,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: Colors.red.shade700,
          end: Colors.yellow.shade600,
        ),
        weight: 33,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.yellow.shade600, end: Colors.orange),
        weight: 34,
      ),
    ]).animate(_controller);

    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- TOP ROW ----
          Row(
            children: [
              widget.icon is Widget
                  ? widget.icon
                  : (widget.animated
                        ? AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Glow effect - outer
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: _colorAnimation.value!
                                              .withOpacity(
                                                0.4 * _scaleAnimation.value,
                                              ),
                                          blurRadius:
                                              20 * _scaleAnimation.value,
                                          spreadRadius:
                                              5 * _scaleAnimation.value,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Main icon
                                  Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: Icon(
                                      widget.icon,
                                      color: _colorAnimation.value,
                                      size: 25,
                                      shadows: [
                                        Shadow(
                                          color: _colorAnimation.value!
                                              .withOpacity(0.8),
                                          blurRadius: 10,
                                        ),
                                        Shadow(
                                          color: Colors.yellow.withOpacity(0.6),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        : Icon(
                            widget.icon as IconData,
                            color: widget.iconColor,
                            size: 25,
                          )),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title1,
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.title2,
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ---- VALUE ----
          Text(
            widget.value,
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
