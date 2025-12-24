import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for IELTS Sentence Completion questions (Section 3, 4)
/// User fills in blanks within sentences
class SentenceCompletionWidget extends StatefulWidget {
  final String questionText;
  final int questionNumber; // Actual question number in the test
  final List<SentenceBlank> sentences; // Sentences with blanks
  final Map<int, String> userAnswers;
  final Function(int, String) onAnswerChanged;

  const SentenceCompletionWidget({
    super.key,
    required this.questionText,
    required this.questionNumber,
    required this.sentences,
    required this.userAnswers,
    required this.onAnswerChanged,
  });

  @override
  State<SentenceCompletionWidget> createState() =>
      _SentenceCompletionWidgetState();
}

class _SentenceCompletionWidgetState extends State<SentenceCompletionWidget> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _controllers = List.generate(
      widget.sentences.length,
      (index) => TextEditingController(text: widget.userAnswers[index] ?? ''),
    );
  }

  @override
  void didUpdateWidget(SentenceCompletionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset controllers when question changes (check questionNumber too)
    if (oldWidget.questionNumber != widget.questionNumber ||
        oldWidget.questionText != widget.questionText ||
        oldWidget.sentences.length != widget.sentences.length) {
      for (var controller in _controllers) {
        controller.dispose();
      }
      _initControllers();
    } else {
      // Same question but maybe userAnswers updated - sync controller text
      for (int i = 0; i < _controllers.length; i++) {
        final expectedText = widget.userAnswers[i] ?? '';
        if (_controllers[i].text != expectedText) {
          _controllers[i].text = expectedText;
        }
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.short_text, color: Colors.orange[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Sentence Completion',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question text
          Text(
            widget.questionText,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: const Color(0xFF333333),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Sentences with blanks
          ...List.generate(widget.sentences.length, (index) {
            final sentence = widget.sentences[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question number (actual number from test)
                    Text(
                      'Question ${widget.questionNumber}',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Sentence with blank visualization
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          color: const Color(0xFF333333),
                          height: 1.6,
                        ),
                        children: _buildSentenceSpans(
                          sentence.textBefore,
                          sentence.textAfter,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Input field
                    TextField(
                      controller: _controllers[index],
                      onChanged: (value) =>
                          widget.onAnswerChanged(index, value),
                      decoration: InputDecoration(
                        hintText: 'Type your answer...',
                        hintStyle: GoogleFonts.lexend(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                        prefixIcon: Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.orange[400],
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.orange[400]!,
                            width: 2,
                          ),
                        ),
                      ),
                      style: GoogleFonts.lexend(fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Hint
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Colors.amber[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Write NO MORE THAN THREE WORDS for each answer.',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      color: Colors.amber[800],
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

  List<TextSpan> _buildSentenceSpans(String before, String after) {
    return [
      TextSpan(text: before),
      TextSpan(
        text: ' __________ ',
        style: GoogleFonts.lexend(
          fontWeight: FontWeight.bold,
          color: Colors.orange[700],
          backgroundColor: Colors.orange.withOpacity(0.1),
        ),
      ),
      TextSpan(text: after),
    ];
  }
}

class SentenceBlank {
  final int id;
  final String textBefore; // Text before the blank
  final String textAfter; // Text after the blank

  SentenceBlank({
    required this.id,
    required this.textBefore,
    required this.textAfter,
  });
}
