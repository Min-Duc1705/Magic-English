import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:magic_enlish/providers/vocabulary/vocabulary_provider.dart';
import 'package:magic_enlish/data/models/vocabulary/Vocabulary.dart';

class FillBlankScreen extends StatefulWidget {
  const FillBlankScreen({super.key});

  @override
  State<FillBlankScreen> createState() => _FillBlankScreenState();
}

class _FillBlankScreenState extends State<FillBlankScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isChecked = false;
  String? _validationError;
  List<Vocabulary> _exercises = [];
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    final provider = Provider.of<VocabularyProvider>(context, listen: false);
    await provider.loadVocabularies();

    if (provider.vocabularies.isEmpty) return;

    setState(() {
      _exercises =
          (provider.vocabularies.where((v) => v.example.isNotEmpty).toList()
                ..shuffle())
              .take(10)
              .toList();
    });
  }

  void _checkAnswer() {
    if (_answerController.text.trim().isEmpty) {
      setState(() {
        _validationError = 'Please enter an answer';
      });
      return;
    }

    setState(() {
      _validationError = null;
      _isChecked = true;
      final userAnswer = _answerController.text.trim().toLowerCase();
      final correctAnswer = _exercises[_currentQuestionIndex].word
          .toLowerCase();

      if (userAnswer == correctAnswer) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _exercises.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isChecked = false;
        _validationError = null;
        _answerController.clear();
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
          'Exercise Complete! 🎉',
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
              '$_score / ${_exercises.length}',
              style: GoogleFonts.lexend(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF10B981), // Green
              ),
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
                _isChecked = false;
                _answerController.clear();
              });
              _loadExercises();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981), // Green
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

  String _getSentenceWithBlank(String example, String word) {
    // Replace the word with blank (_____)
    final regex = RegExp(word, caseSensitive: false);
    return example.replaceFirst(regex, '_____');
  }

  @override
  Widget build(BuildContext context) {
    const practiceColor = Color(0xFF10B981); // Green - accent color only
    const neutral = Color(0xFFE0E0E0);

    if (_exercises.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: Text('Fill in the Blanks', style: GoogleFonts.lexend()),
          backgroundColor: const Color(0xFFF9F9F9),
          foregroundColor: const Color(0xFF333333),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentVocab = _exercises[_currentQuestionIndex];
    final sentenceWithBlank = _getSentenceWithBlank(
      currentVocab.example,
      currentVocab.word,
    );
    final userAnswer = _answerController.text.trim().toLowerCase();
    final correctAnswer = currentVocab.word.toLowerCase();
    final isCorrect = userAnswer == correctAnswer;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Top Bar (quiz style)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                border: Border(
                  bottom: BorderSide(color: neutral.withOpacity(0.3), width: 1),
                ),
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
                    'Fill in the Blanks',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: practiceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Score: $_score',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: practiceColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress Bar (quiz style)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Question ${_currentQuestionIndex + 1} of ${_exercises.length}',
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
                                  _exercises.length,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: practiceColor,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Instruction
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: practiceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: practiceColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Fill in the blank with the correct word',
                              style: GoogleFonts.lexend(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sentence with blank
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        sentenceWithBlank,
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          height: 1.6,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Answer Input
                    TextField(
                      controller: _answerController,
                      enabled: !_isChecked,
                      onChanged: (value) {
                        if (_validationError != null) {
                          setState(() {
                            _validationError = null;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Your Answer',
                        hintText: 'Type the missing word here',
                        prefixIcon: Icon(
                          Icons.edit,
                          color: _validationError != null
                              ? Colors.red
                              : practiceColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: practiceColor,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        enabledBorder: _validationError != null
                            ? OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              )
                            : null,
                      ),
                      style: GoogleFonts.lexend(fontSize: 16),
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                    ),

                    // Validation Error Message
                    if (_validationError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _validationError!,
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Result Display
                    if (_isChecked) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCorrect ? Colors.green : Colors.red,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    isCorrect ? 'Correct! 🎉' : 'Incorrect',
                                    style: GoogleFonts.lexend(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isCorrect
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (!isCorrect) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Correct answer: ${currentVocab.word}',
                                style: GoogleFonts.lexend(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Text(
                              currentVocab.meaning,
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Buttons
                    if (!_isChecked)
                      ElevatedButton(
                        onPressed: _checkAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: practiceColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Check Answer',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: practiceColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentQuestionIndex < _exercises.length - 1
                              ? 'Next Question'
                              : 'Finish Exercise',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
