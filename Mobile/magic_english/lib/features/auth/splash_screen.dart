import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magic_enlish/providers/auth/auth_provider.dart';
import 'package:magic_enlish/features/auth/login_screen.dart';
import 'package:magic_enlish/features/home/home_screen.dart';
import 'package:magic_enlish/features/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginAndOnboarding();
  }

  Future<void> _checkLoginAndOnboarding() async {
    print('🚀 ========== SPLASH SCREEN START ==========');
    // Wait for a minimum time to show splash logo
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    // DEBUG: Print all keys in SharedPreferences
    print('🚀 All SharedPreferences keys: ${prefs.getKeys()}');
    print(
      '🚀 access_token in prefs: ${prefs.getString('access_token') != null}',
    );
    print('🚀 user_id in prefs: ${prefs.getInt('user_id')}');

    // ƯU TIÊN 1: Kiểm tra login status TRƯỚC
    // Nếu đã đăng nhập → đi thẳng HomeScreen (bỏ qua onboarding)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadUser();
    print('🚀 authProvider.isLoggedIn: ${authProvider.isLoggedIn}');

    if (!mounted) return;

    if (authProvider.isLoggedIn) {
      print('🚀 User is logged in → Navigating to HomeScreen');
      // Đánh dấu onboarding đã hoàn thành (vì user đã đăng nhập rồi)
      await prefs.setBool('onboarding_completed', true);
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      return;
    }

    // ƯU TIÊN 2: Nếu chưa đăng nhập, kiểm tra onboarding
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    print('🚀 onboarding_completed: $onboardingCompleted');

    if (!onboardingCompleted) {
      print('🚀 → Navigating to OnboardingScreen');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
      return;
    }

    // ƯU TIÊN 3: Onboarding xong nhưng chưa đăng nhập → LoginScreen
    print('🚀 → Navigating to LoginScreen');
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    print('🚀 ========== SPLASH SCREEN END ==========');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or App Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school_rounded,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Magic English',
              style: GoogleFonts.lexend(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
