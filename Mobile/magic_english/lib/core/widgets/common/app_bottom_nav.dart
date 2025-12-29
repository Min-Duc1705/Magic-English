import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/features/home/home_screen.dart';
import 'package:magic_enlish/features/grammar_checker/grammar_checker_screen.dart';
import 'package:magic_enlish/features/practice/practice_screen.dart';
import 'package:magic_enlish/features/profile/profile_screen.dart';
import 'package:magic_enlish/features/vocabulary/vocabulary_screen.dart';
import 'package:magic_enlish/features/progress/progress_screen.dart';

class AppBottomNav extends StatefulWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff3713ec);

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xfff6f6f8),
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            context,
            icon: Icons.home,
            label: "Home",
            index: 0,
            active: widget.currentIndex == 0,
            page: const HomeScreen(),
          ),
          _navItem(
            context,
            icon: Icons.school,
            label: "Vocab",
            index: 1,
            active: widget.currentIndex == 1,
            page: const VocabularyPage(),
          ),
          _navItem(
            context,
            icon: Icons.spellcheck,
            label: "Grammar",
            index: 2,
            active: widget.currentIndex == 2,
            page: const GrammarCheckerPage(), // TODO
          ),
          _navItem(
            context,
            icon: Icons.fitness_center,
            label: "Practice",
            index: 6,
            active: widget.currentIndex == 6,
            page: const PracticeScreen(), // TODO
          ),
          _navItem(
            context,
            icon: Icons.bar_chart,
            label: "Progress",
            index: 3,
            active: widget.currentIndex == 3,
            page: const ProgressPage(),
          ),
          _navItem(
            context,
            icon: Icons.account_circle,
            label: "Profile",
            index: 4,
            active: widget.currentIndex == 4,
            page: const ProfilePage(), // TODO
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool active,
    required int index,
    required Widget page,
  }) {
    const primary = Color(0xff3713ec);

    return GestureDetector(
      onTap: () {
        if (!active) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => page,
              transitionDuration: const Duration(milliseconds: 250),
              reverseTransitionDuration: const Duration(milliseconds: 250),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    // Scale + Fade transition (zoom in effect)
                    const curve = Curves.easeOutCubic;

                    var scaleTween = Tween<double>(
                      begin: 0.95,
                      end: 1.0,
                    ).chain(CurveTween(curve: curve));
                    var fadeTween = Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).chain(CurveTween(curve: curve));

                    return ScaleTransition(
                      scale: animation.drive(scaleTween),
                      child: FadeTransition(
                        opacity: animation.drive(fadeTween),
                        child: child,
                      ),
                    );
                  },
            ),
          );
        }
      },
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween<double>(begin: 1.0, end: active ? 1.0 : 1.0),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.all(active ? 8 : 0),
                  decoration: BoxDecoration(
                    color: active
                        ? primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: active ? primary : Colors.grey,
                    size: active ? 26 : 24,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  style: GoogleFonts.lexend(
                    fontSize: active ? 12.5 : 12,
                    color: active ? primary : Colors.grey,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
