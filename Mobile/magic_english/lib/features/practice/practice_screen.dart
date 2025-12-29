import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/widgets/common/app_bottom_nav.dart';
import 'package:magic_enlish/features/practice/quiz_mode_screen.dart';
import 'package:magic_enlish/features/practice/fill_blank_screen.dart';
import 'package:magic_enlish/features/practice/listening_practice_screen.dart';
import 'package:magic_enlish/features/practice/speaking_practice_screen.dart';
import 'package:magic_enlish/features/practice/ielts_practice_screen.dart';
import 'package:magic_enlish/features/practice/toeic_practice_screen.dart';
import 'package:provider/provider.dart';
import 'package:magic_enlish/providers/auth/auth_provider.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff1745cf);
    const green = Color(0xFF10B981);
    const purple = Color(0xFF9B59B6);
    const orange = Color(0xFFF97316);
    const red = Color(0xFFEF4444);
    const blue = Color(0xFF3B82F6);
    const teal = Color(0xFF059669);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Top Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/home'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Title
                  Text(
                    'Practice Modes',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const Spacer(),
                  // Profile Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: user?.avatarUrl != null
                          ? Image.network(
                              user!.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  color: Colors.grey[600],
                                  size: 24,
                                );
                              },
                            )
                          : Icon(
                              Icons.person,
                              color: Colors.grey[600],
                              size: 24,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Welcome Header
                    Text(
                      'Ready to Practice?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose an activity to start learning.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Practice Mode Cards Grid (2 columns)
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.0,
                      children: [
                        // Quiz Mode
                        _buildGridCard(
                          context,
                          title: 'Quiz Mode',
                          subtitle: 'Test your vocabulary',
                          icon: Icons.quiz,
                          color: primary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QuizModeScreen(),
                            ),
                          ),
                        ),

                        // Fill in the Blanks
                        _buildGridCard(
                          context,
                          title: 'Fill in the Blanks',
                          subtitle: 'Improve context',
                          icon: Icons.edit_note,
                          color: green,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FillBlankScreen(),
                            ),
                          ),
                        ),

                        // Listening Practice
                        _buildGridCard(
                          context,
                          title: 'Listening',
                          subtitle: 'Sharpen comprehension',
                          icon: Icons.headphones,
                          color: purple,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ListeningPracticeScreen(),
                            ),
                          ),
                        ),

                        // Speaking Practice
                        _buildGridCard(
                          context,
                          title: 'Speaking',
                          subtitle: 'Improve pronunciation',
                          icon: Icons.mic,
                          color: orange,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SpeakingPracticeScreen(),
                            ),
                          ),
                        ),

                        // IELTS Practice
                        _buildGridCard(
                          context,
                          title: 'IELTS',
                          subtitle: 'International exam prep',
                          icon: Icons.school,
                          color: blue,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const IELTSPracticeScreen(),
                            ),
                          ),
                        ),

                        // TOEIC Practice
                        _buildGridCard(
                          context,
                          title: 'TOEIC',
                          subtitle: 'Business English test',
                          icon: Icons.business_center,
                          color: teal,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TOEICPracticeScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const SizedBox(height: 16),

                    // Daily Challenge Card
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Daily Challenge coming soon!',
                              style: GoogleFonts.plusJakartaSans(),
                            ),
                            backgroundColor: red,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F6F8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.local_fire_department,
                                color: red,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Challenge',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'A mix of quick exercises to warm you up.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey[400],
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Coming Soon Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.grey[500], size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'More modes coming soon',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 6),
    );
  }

  Widget _buildGridCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

            // Subtitle
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
