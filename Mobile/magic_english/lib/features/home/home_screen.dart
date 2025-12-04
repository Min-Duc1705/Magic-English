import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/widgets/common/app_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primary = Color(0xff3713ec);

    return Scaffold(
      backgroundColor: const Color(0xfff6f6f8),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- TOP BAR ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.auto_stories, color: primary, size: 32),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Hello, John Doe!",
                      style: GoogleFonts.lexend(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: Colors.black),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // -------- MAIN CONTENT --------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------- 4 STAT CARDS --------
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          icon: Icons.local_fire_department,
                          title: 'Streak',
                          value: '7 days',
                          color: Colors.orange,
                        ),
                        _buildStatCard(
                          icon: Icons.book,
                          title: 'Words Today',
                          value: '12',
                          color: Colors.blue,
                        ),
                        _buildStatCard(
                          icon: Icons.star,
                          title: 'Grammar Checks',
                          value: '45',
                          color: Colors.green,
                        ),
                        _buildStatCard(
                          icon: Icons.trending_up,
                          title: 'Accuracy',
                          value: '85%',
                          color: Colors.purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // -------- QUICK ACTIONS --------
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildActionCard(
                      icon: Icons.add_circle_outline,
                      title: 'Add New Word',
                      subtitle: 'Expand your vocabulary',
                      color: Colors.blue,
                      onTap: () {},
                    ),

                    const SizedBox(height: 12),

                    _buildActionCard(
                      icon: Icons.spellcheck,
                      title: 'Grammar Check',
                      subtitle: 'Check your writing',
                      color: Colors.green,
                      onTap: () {},
                    ),

                    const SizedBox(height: 24),

                    // -------- RECENT WORDS --------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Words',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See all'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Recent Words List
                    _buildWordCard(
                      word: 'Ephemeral',
                      meaning: 'Lasting for a very short time',
                      example: 'The beauty of the sunset was ephemeral.',
                    ),
                    const SizedBox(height: 12),
                    _buildWordCard(
                      word: 'Serendipity',
                      meaning: 'The occurrence of events by chance',
                      example: 'Finding that book was pure serendipity.',
                    ),
                    const SizedBox(height: 12),
                    _buildWordCard(
                      word: 'Ubiquitous',
                      meaning: 'Present everywhere',
                      example: 'Smartphones are ubiquitous in modern life.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCard({
    required String word,
    required String meaning,
    required String example,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                word,
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff3713ec),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
          Text(
            meaning,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '"$example"',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
