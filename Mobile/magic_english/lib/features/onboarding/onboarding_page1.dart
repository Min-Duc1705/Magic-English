import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/utils/backend_utils.dart';

class OnboardingPage1 extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;
  final int currentPage;
  final Function(int) onDotTap;

  const OnboardingPage1({
    super.key,
    required this.onGetStarted,
    required this.onLogin,
    required this.currentPage,
    required this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF135BEC);

    return Column(
      children: [
        // Top Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              Row(
                children: [
                  Icon(Icons.auto_fix_high, color: primaryColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Magic English',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D121B),
                    ),
                  ),
                ],
              ),
              // Login Button
              TextButton(
                onPressed: onLogin,
                child: Text(
                  'Log In',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main Content
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hero Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  height: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: primaryColor.withOpacity(0.05),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Network Image
                        Positioned.fill(
                          child: Image.network(
                            BackendUtils.getImageUrl(
                              localPath: '/onboard/onboard1.png',
                              cloudinaryUrl:
                                  'https://res.cloudinary.com/dekprzmna/image/upload/v1765509905/onboard1_pweeet.png',
                            ),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: primaryColor,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.school,
                                      size: 80,
                                      color: primaryColor.withOpacity(0.6),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '✨ A B C ✨',
                                      style: GoogleFonts.lexend(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor.withOpacity(0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        // Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFFF6F6F8).withOpacity(0.3),
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

              const SizedBox(height: 24),

              // Text Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.lexend(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D121B),
                          height: 1.15,
                        ),
                        children: [
                          const TextSpan(text: 'Welcome to '),
                          TextSpan(
                            text: 'Magic English',
                            style: TextStyle(color: primaryColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The all-in-one AI companion for your English learning journey. Master vocabulary, fix grammar, and track progress.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Footer
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            children: [
              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIndicator(0, currentPage == 0),
                  const SizedBox(width: 12),
                  _buildIndicator(1, currentPage == 1),
                  const SizedBox(width: 12),
                  _buildIndicator(2, currentPage == 2),
                ],
              ),
              const SizedBox(height: 32),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onGetStarted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                    shadowColor: primaryColor.withOpacity(0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
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

  Widget _buildIndicator(int index, bool isActive) {
    return GestureDetector(
      onTap: () => onDotTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 8,
        width: isActive ? 32 : 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isActive ? const Color(0xFF135BEC) : Colors.grey.shade300,
        ),
      ),
    );
  }
}
