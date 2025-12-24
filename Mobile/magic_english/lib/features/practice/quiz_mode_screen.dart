import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:magic_enlish/providers/vocabulary/vocabulary_provider.dart';
import 'package:magic_enlish/data/models/vocabulary/Vocabulary.dart';

class QuizModeScreen extends StatefulWidget {
  const QuizModeScreen({super.key});

  @override
  State<QuizModeScreen> createState() => _QuizModeScreenState();
}

class _QuizModeScreenState extends State<QuizModeScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedAnswerIndex;
  List<Vocabulary> _quizVocabularies = [];
  List<List<String>> _answerOptions = [];

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final provider = Provider.of<VocabularyProvider>(context, listen: false);
    await provider.loadVocabularies();

    if (provider.vocabularies.isEmpty) return;

    setState(() {
      _quizVocabularies = (provider.vocabularies.toList()..shuffle())
          .take(10)
          .toList();
      _answerOptions = _quizVocabularies.map((vocab) {
        final allMeanings = provider.vocabularies
            .where((v) => v.id != vocab.id)
            .map((v) => v.meaning)
            .toList();
        allMeanings.shuffle();

        final options = [vocab.meaning, ...allMeanings.take(3)];
        options.shuffle();
        return options;
      }).toList();
    });
  }

  void _selectAnswer(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;

      final correctAnswer = _quizVocabularies[_currentQuestionIndex].meaning;
      if (_answerOptions[_currentQuestionIndex][index] == correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quizVocabularies.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswerIndex = null;
      });
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Quiz Complete! 🎉',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Score',
              style: GoogleFonts.lexend(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '$_score / ${_quizVocabularies.length}',
              style: GoogleFonts.lexend(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xff3713ec),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${((_score / _quizVocabularies.length) * 100).toStringAsFixed(0)}%',
              style: GoogleFonts.lexend(fontSize: 20, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Back', style: GoogleFonts.lexend()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _isAnswered = false;
                _selectedAnswerIndex = null;
              });
              _loadQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff3713ec),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.lexend(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4A90E2);
    const correct = Color(0xFF7ED321);
    const incorrect = Color(0xFFD0021B);
    const neutral = Color(0xFFE0E0E0);

    if (_quizVocabularies.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: Text('Quiz Mode', style: GoogleFonts.lexend()),
          backgroundColor: const Color(0xFFF9F9F9),
          foregroundColor: const Color(0xFF333333),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentVocab = _quizVocabularies[_currentQuestionIndex];
    final options = _answerOptions[_currentQuestionIndex];
    final correctAnswer = currentVocab.meaning;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                border: Border(
                  bottom: BorderSide(color: neutral.withOpacity(0.3), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 35,
                      height: 35,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close,
                        size: 28,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Quiz Mode',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 35),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Progress Bar
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Question ${_currentQuestionIndex + 1} of ${_quizVocabularies.length}',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: neutral.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(9999),
                              ),
                            ),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor:
                                  (_currentQuestionIndex + 1) /
                                  _quizVocabularies.length,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // Question Area
                    Column(
                      children: [
                        Text(
                          'What does this word mean?',
                          style: GoogleFonts.lexend(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentVocab.word,
                          style: GoogleFonts.lexend(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (currentVocab.ipa.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            '/${currentVocab.ipa}/',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF666666),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Answer Options
                    ...List.generate(options.length, (index) {
                      final isSelected = _selectedAnswerIndex == index;
                      final isCorrect = options[index] == correctAnswer;

                      Color getBorderColor() {
                        if (!_isAnswered) return neutral.withOpacity(0.8);
                        if (isCorrect) return correct;
                        if (isSelected && !isCorrect) return incorrect;
                        return neutral.withOpacity(0.8);
                      }

                      Color getBgColor() {
                        if (!_isAnswered) return Colors.transparent;
                        if (isCorrect) return correct.withOpacity(0.1);
                        if (isSelected && !isCorrect) {
                          return incorrect.withOpacity(0.1);
                        }
                        return Colors.transparent;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _selectAnswer(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: getBgColor(),
                              border: Border.all(
                                color: getBorderColor(),
                                width: _isAnswered && (isCorrect || isSelected)
                                    ? 2
                                    : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Radio Button
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: getBorderColor(),
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? getBorderColor()
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? Center(
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    options[index],
                                    style: GoogleFonts.lexend(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF333333),
                                    ),
                                  ),
                                ),
                                if (_isAnswered && isCorrect)
                                  Icon(
                                    Icons.check_circle,
                                    color: correct,
                                    size: 24,
                                  ),
                                if (_isAnswered && isSelected && !isCorrect)
                                  Icon(
                                    Icons.cancel,
                                    color: incorrect,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    // Feedback Banner
                    if (_isAnswered) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              (_answerOptions[_currentQuestionIndex][_selectedAnswerIndex!] ==
                                          correctAnswer
                                      ? correct
                                      : incorrect)
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _answerOptions[_currentQuestionIndex][_selectedAnswerIndex!] ==
                                      correctAnswer
                                  ? 'Correct!'
                                  : 'Incorrect!',
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    _answerOptions[_currentQuestionIndex][_selectedAnswerIndex!] ==
                                        correctAnswer
                                    ? correct
                                    : incorrect,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "The right answer is '$correctAnswer'.",
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                color: const Color(0xFF333333),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                border: Border(
                  top: BorderSide(color: neutral.withOpacity(0.5), width: 1),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Skip Button
                  TextButton.icon(
                    onPressed: _isAnswered ? null : _nextQuestion,
                    icon: const Icon(Icons.skip_next, size: 20),
                    label: Text(
                      'Skip',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF333333).withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Next Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isAnswered ? _nextQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: neutral,
                      ),
                      child: Text(
                        _currentQuestionIndex < _quizVocabularies.length - 1
                            ? 'Next'
                            : 'Finish',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Back Button
                  TextButton.icon(
                    onPressed: _currentQuestionIndex > 0
                        ? () {
                            setState(() {
                              _currentQuestionIndex--;
                              _selectedAnswerIndex = null;
                              _isAnswered = false;
                            });
                          }
                        : null,
                    icon: Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: _currentQuestionIndex > 0
                          ? const Color(0xFF333333).withOpacity(0.8)
                          : const Color(0xFFCCCCCC),
                    ),
                    label: Text(
                      'Back',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _currentQuestionIndex > 0
                            ? const Color(0xFF333333).withOpacity(0.8)
                            : const Color(0xFFCCCCCC),
                      ),
                    ),
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
