import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for IELTS Form Completion questions (Section 1, 2)
/// User fills in form fields based on audio
class FormCompletionWidget extends StatefulWidget {
  final String formTitle;
  final List<String> blanks; // Field labels to fill
  final Map<int, String> userAnswers;
  final Function(int, String) onAnswerChanged;

  const FormCompletionWidget({
    super.key,
    required this.formTitle,
    required this.blanks,
    required this.userAnswers,
    required this.onAnswerChanged,
  });

  @override
  State<FormCompletionWidget> createState() => _FormCompletionWidgetState();
}

class _FormCompletionWidgetState extends State<FormCompletionWidget> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _controllers = List.generate(
      widget.blanks.length,
      (index) => TextEditingController(text: widget.userAnswers[index] ?? ''),
    );
  }

  @override
  void didUpdateWidget(FormCompletionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset controllers only when question CONTENT actually changes
    // Compare by content, not object identity
    bool blanksChanged = oldWidget.blanks.length != widget.blanks.length;
    if (!blanksChanged && widget.blanks.isNotEmpty) {
      for (int i = 0; i < widget.blanks.length; i++) {
        if (oldWidget.blanks[i] != widget.blanks[i]) {
          blanksChanged = true;
          break;
        }
      }
    }

    if (blanksChanged) {
      for (var controller in _controllers) {
        controller.dispose();
      }
      _initControllers();
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
              Icon(Icons.note_alt, color: const Color(0xFF4A90E2), size: 20),
              const SizedBox(width: 8),
              Text(
                'Form Completion',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A90E2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Instruction
          Text(
            'Complete the form based on what you hear:',
            style: GoogleFonts.lexend(fontSize: 13, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),

          // Form fields
          ...List.generate(widget.blanks.length, (index) {
            return _buildFormField(index);
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
                    'Write NO MORE THAN TWO WORDS for each answer.',
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

  Widget _buildFormField(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.blanks[index],
              style: GoogleFonts.lexend(
                fontSize: 13,
                color: const Color(0xFF4A90E2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Input field
          Expanded(
            child: TextField(
              controller: _controllers[index],
              onChanged: (value) => widget.onAnswerChanged(index, value),
              decoration: InputDecoration(
                hintText: 'Type answer...',
                hintStyle: GoogleFonts.lexend(
                  fontSize: 13,
                  color: Colors.grey[400],
                ),
                filled: true,
                fillColor: Colors.grey[50],
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
                  borderSide: const BorderSide(
                    color: Color(0xFF4A90E2),
                    width: 2,
                  ),
                ),
              ),
              style: GoogleFonts.lexend(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
