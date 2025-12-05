import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/widgets/common/app_bottom_nav.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4A90E2);
    const background = Color(0xFFF9F9F9);
    const textColor = Color(0xFF100d1b);

    // Static progress data
    final Map<String, dynamic> progressData = {
      'streakDays': 7,
      'wordsToday': 12,
      'totalWords': 156,
      'accuracy': 85,
      'testScores': [
        {'date': 'Jan 15', 'score': 65},
        {'date': 'Jan 22', 'score': 72},
        {'date': 'Jan 29', 'score': 78},
        {'date': 'Feb 05', 'score': 82},
        {'date': 'Feb 12', 'score': 85},
      ],
      'skillProgress': [
        {'skill': 'Reading', 'progress': 0.85, 'level': 'Advanced'},
        {'skill': 'Writing', 'progress': 0.72, 'level': 'Intermediate'},
        {'skill': 'Listening', 'progress': 0.68, 'level': 'Intermediate'},
        {'skill': 'Speaking', 'progress': 0.60, 'level': 'Beginner'},
      ],
      'recentActivities': [
        {
          'type': 'vocabulary',
          'title': 'Added 5 new words',
          'date': '2 hours ago',
          'icon': Icons.book,
          'color': Colors.blue,
        },
        {
          'type': 'test',
          'title': 'Completed TOEIC Practice',
          'date': '1 day ago',
          'icon': Icons.assignment,
          'color': Colors.green,
        },
        {
          'type': 'grammar',
          'title': 'Grammar check completed',
          'date': '2 days ago',
          'icon': Icons.spellcheck,
          'color': Colors.orange,
        },
      ],
    };

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: const Icon(Icons.arrow_back, size: 24),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'My Progress',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      color: textColor,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Grid
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
                          value: '${progressData['streakDays']} days',
                          color: Colors.orange,
                        ),
                        _buildStatCard(
                          icon: Icons.book,
                          title: 'Words Today',
                          value: '${progressData['wordsToday']}',
                          color: Colors.blue,
                        ),
                        _buildStatCard(
                          icon: Icons.library_books,
                          title: 'Total Words',
                          value: '${progressData['totalWords']}',
                          color: Colors.green,
                        ),
                        _buildStatCard(
                          icon: Icons.trending_up,
                          title: 'Accuracy',
                          value: '${progressData['accuracy']}%',
                          color: Colors.purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Test Scores Chart
                    Text(
                      'Test Score Progress',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: CustomPaint(
                              size: const Size(double.infinity, 200),
                              painter: LineChartPainter(
                                scores: (progressData['testScores'] as List)
                                    .map((e) => (e['score'] as int).toDouble())
                                    .toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: (progressData['testScores'] as List)
                                .map((e) => Text(
                                      e['date'],
                                      style: GoogleFonts.lexend(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Skill Progress
                    Text(
                      'Skill Progress',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...(progressData['skillProgress'] as List).map((skill) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSkillCard(
                          skill: skill['skill'],
                          progress: skill['progress'],
                          level: skill['level'],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Recent Activities
                    Text(
                      'Recent Activities',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...(progressData['recentActivities'] as List).map((activity) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildActivityCard(
                          icon: activity['icon'],
                          title: activity['title'],
                          date: activity['date'],
                          color: activity['color'],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
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

  Widget _buildSkillCard({
    required String skill,
    required double progress,
    required String level,
  }) {
    Color progressColor;
    if (progress >= 0.75) {
      progressColor = Colors.green;
    } else if (progress >= 0.5) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

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
                skill,
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  level,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String date,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  final List<double> scores;

  LineChartPainter({required this.scores});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF4A90E2).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    if (scores.isEmpty) return;

    final maxScore = 100.0;
    final stepX = size.width / (scores.length - 1);

    // Start path
    path.moveTo(0, size.height - (scores[0] / maxScore * size.height));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height - (scores[0] / maxScore * size.height));

    for (int i = 1; i < scores.length; i++) {
      final x = stepX * i;
      final y = size.height - (scores[i] / maxScore * size.height);
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    // Complete fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill and line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < scores.length; i++) {
      final x = stepX * i;
      final y = size.height - (scores[i] / maxScore * size.height);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
      canvas.drawCircle(Offset(x, y), 6, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
