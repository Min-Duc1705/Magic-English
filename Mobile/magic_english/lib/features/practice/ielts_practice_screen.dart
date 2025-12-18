import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/data/services/ielts_service.dart';
import 'package:magic_enlish/features/practice/ielts_take_test_screen.dart';

class IELTSPracticeScreen extends StatefulWidget {
  const IELTSPracticeScreen({super.key});

  @override
  State<IELTSPracticeScreen> createState() => _IELTSPracticeScreenState();
}

class _IELTSPracticeScreenState extends State<IELTSPracticeScreen> {
  final IELTSService _ieltsService = IELTSService();

  String _selectedSkill = 'Reading';
  String _selectedLevel = 'General';
  bool _isGenerating = false;

  final List<String> _skills = ['Reading', 'Writing', 'Listening', 'Speaking'];
  final List<String> _levels = ['General', 'Academic'];

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xff1745cf);

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
          'IELTS Practice',
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
            // Header Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IELTS Preparation',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'International English Language Testing System',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Select Test Type
            Text(
              'Test Type',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: _levels.map((level) {
                final isSelected = _selectedLevel == level;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLevel = level;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? primary : const Color(0xFFF6F6F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          level,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Select Skill
            Text(
              'Select Skill',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              children: _skills.map((skill) {
                final isSelected = _selectedSkill == skill;
                IconData icon;
                switch (skill) {
                  case 'Reading':
                    icon = Icons.menu_book;
                    break;
                  case 'Writing':
                    icon = Icons.edit;
                    break;
                  case 'Listening':
                    icon = Icons.headphones;
                    break;
                  case 'Speaking':
                    icon = Icons.mic;
                    break;
                  default:
                    icon = Icons.book;
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSkill = skill;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primary.withOpacity(0.1)
                          : const Color(0xFFF6F6F8),
                      border: Border.all(
                        color: isSelected ? primary : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: isSelected ? primary : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          skill,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? primary
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Practice Tests
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
                        '$_selectedLevel $_selectedSkill Test $testNumber',
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
            onPressed: _isGenerating ? null : () => _startTest(difficulty),
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

  Future<void> _startTest(String difficulty) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Generating IELTS Test...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI is creating your $_selectedLevel $_selectedSkill test',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

      // Generate test
      final test = await _ieltsService.generateTest(
        skill: _selectedSkill,
        level: _selectedLevel,
        difficulty: difficulty,
      );

      // Start test session
      final history = await _ieltsService.startTest(test.id);

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to test screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              IELTSTakeTestScreen(test: test, history: history),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog if open
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to generate test: ${e.toString()}',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }
}
