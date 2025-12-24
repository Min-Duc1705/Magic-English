import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magic_enlish/features/auth/login_screen.dart';
import 'onboarding_page1.dart';
import 'onboarding_page2.dart';
import 'onboarding_page3.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skip() {
    _completeOnboarding();
  }

  void _startLearning() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  OnboardingPage1(
                    onGetStarted: _nextPage,
                    onLogin: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    currentPage: _currentPage,
                    onDotTap: _goToPage,
                  ),
                  OnboardingPage2(
                    onNext: _nextPage,
                    onSkip: _skip,
                    currentPage: _currentPage,
                    onDotTap: _goToPage,
                  ),
                  OnboardingPage3(
                    onStartLearning: _startLearning,
                    onSkip: _skip,
                    currentPage: _currentPage,
                    onDotTap: _goToPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
