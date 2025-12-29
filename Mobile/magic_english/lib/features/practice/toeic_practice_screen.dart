import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/services/toeic_service.dart';
import 'toeic_take_test_screen.dart';

class TOEICPracticeScreen extends StatefulWidget {
  const TOEICPracticeScreen({super.key});

  @override
  State<TOEICPracticeScreen> createState() => _TOEICPracticeScreenState();
}

class _TOEICPracticeScreenState extends State<TOEICPracticeScreen> {
  String _selectedSection = 'Listening';
  bool _isGenerating = false;
  final ToeicService _toeicService = ToeicService();

  final List<Map<String, dynamic>> _sections = [
    {
      'name': 'Listening',
      'icon': Icons.headphones,
      'duration': '45 min',
      'questions': 100,
    },
    {
      'name': 'Reading',
      'icon': Icons.menu_book,
      'duration': '75 min',
      'questions': 100,
    },
    {
      'name': 'Part 1-4',
      'icon': Icons.music_note,
      'duration': '45 min',
      'questions': 100,
    },
    {
      'name': 'Part 5-7',
      'icon': Icons.article,
      'duration': '75 min',
      'questions': 100,
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF059669); // Teal for TOEIC

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'TOEIC Practice',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section - Premium Design
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF059669),
                    Color(0xFF10B981),
                    Color(0xFF34D399),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 60,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Glossy Icon Container
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.psychology,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TOEIC Preparation',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Test of English for International Communication',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.85),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Stats Row
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildHeaderStat(
                                '200',
                                'Questions',
                                Icons.quiz_outlined,
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              _buildHeaderStat(
                                '2h',
                                'Duration',
                                Icons.timer_outlined,
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              _buildHeaderStat(
                                '990',
                                'Max Score',
                                Icons.emoji_events_outlined,
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

            const SizedBox(height: 24),

            // Select Section - Combined list
            Text(
              'Select Section',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),

            // Section Cards List
            ..._sections.map(
              (section) => _buildSectionCard(
                section: section,
                isSelected: _selectedSection == section['name'],
                primary: primary,
                onTap: () {
                  setState(() {
                    _selectedSection = section['name'] as String;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // Available Tests
            Text(
              'Available Tests',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),

            ...List.generate(3, (index) {
              final difficulty = index == 0
                  ? 'Easy'
                  : index == 1
                  ? 'Medium'
                  : 'Hard';
              final questions = index == 0
                  ? 10
                  : index == 1
                  ? 15
                  : 20;
              return _buildTestCard(
                context,
                testNumber: index + 1,
                duration: '20 minutes',
                questions: questions,
                difficulty: difficulty,
                primary: primary,
              );
            }),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required Map<String, dynamic> section,
    required bool isSelected,
    required Color primary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? primary.withOpacity(0.1)
              : Colors.white, // White background for unselected
          border: Border.all(
            color: isSelected
                ? primary
                : Colors.grey[200]!, // Subtle border for unselected
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16), // Rounded corners
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ], // Soft shadow for unselected
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? primary.withOpacity(0.2)
                    : primary.withOpacity(
                        0.08,
                      ), // Light colored background for icon always
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                section['icon'] as IconData,
                color: isSelected
                    ? primary
                    : primary.withOpacity(0.7), // Colored icon always
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['name'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        section['duration'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.help_outline,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${section['questions']} questions',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primary : Colors.transparent,
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey[300]!, width: 1.5),
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.arrow_forward_ios_rounded,
                color: isSelected ? Colors.white : Colors.grey[400],
                size: isSelected ? 16 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(
    BuildContext context, {
    required int testNumber,
    required String duration,
    required int questions,
    required String difficulty,
    required Color primary,
  }) {
    Color difficultyColor;
    switch (difficulty) {
      case 'Easy':
        difficultyColor = const Color(0xFF10B981);
        break;
      case 'Medium':
        difficultyColor = const Color(0xFFF59E0B);
        break;
      case 'Hard':
        difficultyColor = const Color(0xFFEF4444);
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$testNumber',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$_selectedSection Test $testNumber',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: difficultyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        difficulty,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: difficultyColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '20 min',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.help_outline, size: 13, color: Colors.grey[600]),
                    const SizedBox(width: 3),
                    Text(
                      '$questions qs',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _isGenerating
                ? null
                : () => _generateAndStartTest(difficulty),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor: Colors.grey[400],
            ),
            child: _isGenerating
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Start',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndStartTest(String difficulty) async {
    if (_isGenerating) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF059669)),
              const SizedBox(height: 16),
              Text(
                'Generating TOEIC Test...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This may take a few seconds',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );

      // Generate test
      final test = await _toeicService.generateTest(
        _selectedSection,
        difficulty,
      );

      // Start test session
      final history = await _toeicService.startTest(test.id);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Navigate to take test screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ToeicTakeTestScreen(test: test, historyId: history.id),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context).pop();

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFEF4444)),
                const SizedBox(width: 8),
                Text(
                  'Error',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              'Failed to generate test: ${e.toString()}',
              style: GoogleFonts.plusJakartaSans(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}
