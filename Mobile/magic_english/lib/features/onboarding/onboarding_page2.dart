import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage2 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final int currentPage;
  final Function(int) onDotTap;

  const OnboardingPage2({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.currentPage,
    required this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF135BEC);

    return Column(
      children: [
        // Skip Button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onSkip,
                child: Text(
                  'Skip',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Input Field Visual
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type a word...',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Serendipity',
                            style: GoogleFonts.lexend(
                              fontSize: 18,
                              color: const Color(0xFF0D121B),
                            ),
                          ),
                          Icon(Icons.edit, color: primaryColor, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),

                // Magic Transition Arrow
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 48,
                        width: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.grey.shade300,
                              primaryColor,
                              Colors.grey.shade300,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.4),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // Enriched Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Image Header
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withOpacity(0.8),
                              Colors.purple.withOpacity(0.6),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.6),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  'C2 Level',
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Serendipity',
                                      style: GoogleFonts.lexend(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0D121B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '/ˌser.ənˈdɪp.ə.ti/',
                                      style: GoogleFonts.lexend(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.volume_up,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(height: 1, color: Colors.grey.shade100),
                            const SizedBox(height: 12),
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Noun: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0D121B),
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        'Finding something good without looking for it.',
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

                const SizedBox(height: 32),

                // Text Content
                Text(
                  'Instant Vocabulary Magic',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D121B),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Type a word and let our AI do the rest. Get meanings, IPA, and context in seconds.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
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
                  const SizedBox(width: 8),
                  _buildIndicator(1, currentPage == 1),
                  const SizedBox(width: 8),
                  _buildIndicator(2, currentPage == 2),
                ],
              ),
              const SizedBox(height: 24),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                    shadowColor: primaryColor.withOpacity(0.3),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildIndicator(int index, bool isActive) {
    return GestureDetector(
      onTap: () => onDotTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 8,
        width: isActive ? 24 : 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isActive ? const Color(0xFF135BEC) : Colors.grey.shade300,
        ),
      ),
    );
  }
}
