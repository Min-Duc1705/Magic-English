import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for IELTS Flow-chart Completion questions (Section 4)
/// User fills in blanks in a process flow diagram
class FlowchartWidget extends StatefulWidget {
  final String questionText;
  final int questionNumber; // Actual question number in the test
  final List<FlowchartStep> steps;
  final Map<int, String> userAnswers;
  final Function(int, String) onAnswerChanged;

  const FlowchartWidget({
    super.key,
    required this.questionText,
    required this.questionNumber,
    required this.steps,
    required this.userAnswers,
    required this.onAnswerChanged,
  });

  @override
  State<FlowchartWidget> createState() => _FlowchartWidgetState();
}

class _FlowchartWidgetState extends State<FlowchartWidget> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _controllers = [];
    for (int i = 0; i < widget.steps.length; i++) {
      if (widget.steps[i].hasBlank) {
        _controllers.add(
          TextEditingController(text: widget.userAnswers[i] ?? ''),
        );
      }
    }
  }

  @override
  void didUpdateWidget(FlowchartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset controllers when question changes
    if (oldWidget.questionNumber != widget.questionNumber ||
        oldWidget.steps.length != widget.steps.length) {
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
    int controllerIndex = 0;

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
              Icon(Icons.account_tree, color: Colors.indigo[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Flow-chart Completion',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[700],
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
          const SizedBox(height: 20),

          // Flowchart steps
          ...List.generate(widget.steps.length, (index) {
            final step = widget.steps[index];
            final isLast = index == widget.steps.length - 1;

            Widget stepWidget = Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: step.hasBlank
                    ? Colors.indigo.withOpacity(0.05)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: step.hasBlank
                      ? Colors.indigo.withOpacity(0.3)
                      : Colors.grey[300]!,
                  width: step.hasBlank ? 2 : 1,
                ),
              ),
              child: step.hasBlank
                  ? _buildBlankStep(step, controllerIndex++, index)
                  : _buildNormalStep(step),
            );

            return Column(
              children: [
                stepWidget,
                if (!isLast) ...[
                  // Arrow down
                  SizedBox(
                    height: 30,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 2,
                          height: 30,
                          color: Colors.indigo[300],
                        ),
                        Positioned(
                          bottom: 0,
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.indigo[400],
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          }),

          const SizedBox(height: 16),

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

  Widget _buildNormalStep(FlowchartStep step) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step.stepNumber}',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            step.text,
            style: GoogleFonts.lexend(
              fontSize: 13,
              color: const Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBlankStep(FlowchartStep step, int ctrlIndex, int stepIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.indigo[100],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${widget.questionNumber}',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[700],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    color: const Color(0xFF333333),
                  ),
                  children: [
                    TextSpan(text: step.textBefore ?? ''),
                    TextSpan(
                      text: ' [____] ',
                      style: GoogleFonts.lexend(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[700],
                      ),
                    ),
                    TextSpan(text: step.textAfter ?? ''),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _controllers[ctrlIndex],
          onChanged: (value) => widget.onAnswerChanged(stepIndex, value),
          decoration: InputDecoration(
            hintText: 'Type answer...',
            hintStyle: GoogleFonts.lexend(
              fontSize: 13,
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(Icons.edit, size: 18, color: Colors.indigo[400]),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.indigo[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.indigo[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.indigo[600]!, width: 2),
            ),
          ),
          style: GoogleFonts.lexend(fontSize: 13),
        ),
      ],
    );
  }
}

class FlowchartStep {
  final int stepNumber;
  final String text;
  final bool hasBlank;
  final String? textBefore; // Text before blank (if hasBlank)
  final String? textAfter; // Text after blank (if hasBlank)

  FlowchartStep({
    required this.stepNumber,
    required this.text,
    this.hasBlank = false,
    this.textBefore,
    this.textAfter,
  });
}
