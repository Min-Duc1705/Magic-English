import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/utils/backend_utils.dart';

class OnboardingPage3 extends StatelessWidget {
  final VoidCallback onStartLearning;
  final VoidCallback onSkip;
  final int currentPage;
  final Function(int) onDotTap;

  const OnboardingPage3({
    super.key,
    required this.onStartLearning,
    required this.onSkip,
    required this.currentPage,
    required this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF135BEC);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme Colors
    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;
    final cardColor = isDark ? const Color(0xFF2D2D2D) : Colors.white;
    final cardSurfaceColor = isDark
        ? const Color(0xFF1E1E1E)
        : Colors.grey.shade50;
    final textPrimary = isDark ? Colors.white : const Color(0xFF0D121B);
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final textSecondaryLight = isDark
        ? Colors.grey.shade400
        : Colors.grey.shade600;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;
    final iconBgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final inactiveDot = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final shadowColor = isDark
        ? Colors.transparent
        : Colors.black.withOpacity(0.02);

    return Container(
      color: bgColor,
      child: Column(
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
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
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
                  const SizedBox(height: 8),

                  // Grammar Correction Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardSurfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // AI Badge
                        Positioned(
                          top: -36,
                          right: -12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'AI Check',
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Column(
                          children: [
                            // User Input
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // User Avatar
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: iconBgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      BackendUtils.getImageUrl(
                                        localPath: '/onboard/onboard3.png',
                                        cloudinaryUrl:
                                            'https://res.cloudinary.com/dekprzmna/image/upload/v1765509905/onboard3_oqcynm.png',
                                      ),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.person,
                                        color: Colors.grey.shade400,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                      border: Border.all(color: borderColor),
                                      boxShadow: [
                                        BoxShadow(
                                          color: shadowColor,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.lexend(
                                          fontSize: 14,
                                          color: textSecondaryLight,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: 'I am ready to ',
                                          ),
                                          TextSpan(
                                            text: 'learning',
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor:
                                                  Colors.red.shade400,
                                              decorationThickness: 2,
                                              color: Colors.red.shade300,
                                            ),
                                          ),
                                          const TextSpan(text: ' English.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // AI Response
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                      border: Border.all(
                                        color: primaryColor.withOpacity(0.1),
                                      ),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.lexend(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: textPrimary,
                                        ),
                                        children: [
                                          const TextSpan(
                                            text: 'Suggestion: I am ready to ',
                                          ),
                                          TextSpan(
                                            text: 'learn',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.green.shade400
                                                  : Colors.green.shade600,
                                            ),
                                          ),
                                          const TextSpan(text: ' English.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.smart_toy,
                                    color: primaryColor,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats Row
                  Row(
                    children: [
                      // Streak Card
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.local_fire_department,
                          iconColor: Colors.orange,
                          bgGradient: isDark
                              ? [
                                  Colors.orange.withOpacity(0.1),
                                  Colors.orange.withOpacity(0.05),
                                ]
                              : [Colors.orange.shade50, Colors.orange.shade100],
                          borderColor: isDark
                              ? Colors.orange.withOpacity(0.3)
                              : Colors.orange.shade200,
                          label: 'Current Streak',
                          value: '3 Days',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Level Card
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.emoji_events,
                          iconColor: primaryColor,
                          bgGradient: isDark
                              ? [
                                  Colors.indigo.withOpacity(0.1),
                                  Colors.indigo.withOpacity(0.05),
                                ]
                              : [Colors.blue.shade50, Colors.indigo.shade100],
                          borderColor: isDark
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.blue.shade200,
                          label: 'Fluency Level',
                          value: 'B2 Int.',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Footer Area
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                // Title
                Text(
                  'Perfect Grammar &\nTrack Progress',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Get instant AI feedback on your writing and watch your fluency score grow every single day.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 15,
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIndicator(0, currentPage == 0, inactiveDot),
                    const SizedBox(width: 12),
                    _buildIndicator(1, currentPage == 1, inactiveDot),
                    const SizedBox(width: 12),
                    _buildIndicator(2, currentPage == 2, inactiveDot),
                  ],
                ),
                const SizedBox(height: 32),

                // Start Learning Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: onStartLearning,
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
                          'Start Learning',
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
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required List<Color> bgGradient,
    required Color borderColor,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bgGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0D121B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index, bool isActive, Color inactiveColor) {
    return GestureDetector(
      onTap: () => onDotTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 10,
        width: isActive ? 32 : 10,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: isActive ? const Color(0xFF135BEC) : inactiveColor,
        ),
      ),
    );
  }
}
