import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/data/models/ielts/ielts_test.dart';

class IELTSResultScreen extends StatelessWidget {
  final IELTSTestResult result;
  final IELTSTest test;

  const IELTSResultScreen({
    super.key,
    required this.result,
    required this.test,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4A90E2);
    const correct = Color(0xFF7ED321);
    const incorrect = Color(0xFFD0021B);

    final percentage = (result.correctAnswers / result.totalQuestions * 100)
        .round();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          'Test Results',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111827),
          ),
        ),
        backgroundColor: const Color(0xFFF9F9F9),
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context); // Go back to IELTS practice screen
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'IELTS Band Score',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.score.toStringAsFixed(1),
                    style: GoogleFonts.lexend(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Correct',
                        '${result.correctAnswers}/${result.totalQuestions}',
                        correct,
                      ),
                      Container(width: 1, height: 40, color: Colors.white30),
                      _buildStatItem('Accuracy', '$percentage%', Colors.white),
                      Container(width: 1, height: 40, color: Colors.white30),
                      _buildStatItem(
                        'Time',
                        _formatTime(result.timeSpentSeconds),
                        Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Test Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    test.title,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildChip(test.skill, primary),
                      const SizedBox(width: 8),
                      _buildChip(test.level, Colors.orange),
                      const SizedBox(width: 8),
                      _buildChip(
                        test.difficulty,
                        _getDifficultyColor(test.difficulty),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Questions Review Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Questions Review',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  '${result.questionResults.length} questions',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Questions List
            ...result.questionResults.asMap().entries.map((entry) {
              final questionResult = entry.value;
              final question = test.questions.firstWhere(
                (q) => q.id == questionResult.questionId,
              );

              return _buildQuestionResultCard(
                questionResult,
                question,
                correct,
                incorrect,
              );
            }),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pop(context); // Go back to IELTS practice screen
        },
        backgroundColor: primary,
        icon: const Icon(Icons.check, color: Colors.white),
        label: Text(
          'Done',
          style: GoogleFonts.lexend(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lexend(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildQuestionResultCard(
    IELTSQuestionResult questionResult,
    IELTSQuestion question,
    Color correct,
    Color incorrect,
  ) {
    final isCorrect = questionResult.isCorrect;
    final statusColor = isCorrect ? correct : incorrect;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Number and Status
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${questionResult.questionNumber}',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isCorrect ? 'Correct' : 'Incorrect',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: statusColor,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Passage (Reading or Listening)
          if (question.passage != null && question.passage!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: test.skill == 'Listening'
                    ? Colors.blue.withOpacity(0.05)
                    : test.skill == 'Writing'
                    ? Colors.purple.withOpacity(0.05)
                    : Colors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: test.skill == 'Listening'
                      ? Colors.blue.withOpacity(0.2)
                      : test.skill == 'Writing'
                      ? Colors.purple.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        test.skill == 'Listening'
                            ? Icons.headphones
                            : test.skill == 'Writing'
                            ? Icons.edit_note
                            : Icons.menu_book,
                        size: 16,
                        color: test.skill == 'Listening'
                            ? Colors.blue[700]
                            : test.skill == 'Writing'
                            ? Colors.purple[700]
                            : Colors.green[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        test.skill == 'Listening'
                            ? 'Audio Transcript'
                            : test.skill == 'Writing'
                            ? 'Writing Task'
                            : 'Reading Passage',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: test.skill == 'Listening'
                              ? Colors.blue[700]
                              : test.skill == 'Writing'
                              ? Colors.purple[700]
                              : Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.passage!,
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Question Text - Remove 'Options:...' for matching, remove instruction for flowchart
          Text(
            question.questionType == 'matching'
                ? questionResult.questionText.split('Options:')[0].trim()
                : question.questionType == 'flowchart'
                ? questionResult.questionText.split('Step 1:')[0].trim()
                : questionResult.questionText,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),

          // Answers/Essay Result
          if (question.questionType == 'essay') ...[
            // Writing Essay Result
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Your Essay
                  Text(
                    'Your Essay:',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: SingleChildScrollView(
                      child: Text(
                        questionResult.userAnswer.isNotEmpty
                            ? questionResult.userAnswer
                            : '(No essay submitted)',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          color: const Color(0xFF333333),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // AI Feedback
                  if (questionResult.explanation != null &&
                      questionResult.explanation!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? Colors.green.withOpacity(0.05)
                            : Colors.orange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isCorrect
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.rate_review,
                            size: 18,
                            color: isCorrect
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Feedback',
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isCorrect
                                        ? Colors.green[700]
                                        : Colors.orange[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  questionResult.explanation!,
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ] else if (question.questionType == 'matching' ||
              question.questionType == 'flowchart') ...[
            // Matching/Flowchart Question Result - Show user answer vs correct answer
            Builder(
              builder: (context) {
                // Parse user answers from format "0:A,1:B,2:C,3:D"
                final userAnswerMap = <int, String>{};
                if (questionResult.userAnswer.isNotEmpty) {
                  final pairs = questionResult.userAnswer.split(',');
                  for (var pair in pairs) {
                    final parts = pair.split(':');
                    if (parts.length == 2) {
                      final index = int.tryParse(parts[0].trim());
                      if (index != null) {
                        userAnswerMap[index] = parts[1].trim();
                      }
                    }
                  }
                }

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Builder(
                        builder: (context) {
                          final isFlowchartQ =
                              question.questionType == 'flowchart';
                          return Row(
                            children: [
                              const SizedBox(width: 34),
                              Expanded(
                                child: Text(
                                  isFlowchartQ ? 'Step' : 'Item',
                                  style: GoogleFonts.lexend(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: isFlowchartQ ? 60 : 45,
                                child: Text(
                                  'You',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lexend(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: isFlowchartQ ? 80 : 45,
                                child: Text(
                                  'Answer',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lexend(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      // Show each item's answer
                      ...question.answers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final answer = entry.value;
                        final itemNum = index + 1;

                        // For flowchart: compare text answers
                        // For matching: compare letters
                        bool isFlowchartType =
                            question.questionType == 'flowchart';

                        // Get correct answer
                        String correctAnswer = isFlowchartType
                            ? answer
                                  .answerText // Flowchart: actual word
                            : answer.answerOption; // Matching: letter A,B,C,D

                        // Get user's answer
                        String userAnswer = userAnswerMap[index] ?? '?';

                        // Check if correct
                        bool itemCorrect = isFlowchartType
                            ? userAnswer.toLowerCase() ==
                                  correctAnswer.toLowerCase()
                            : userAnswer.toUpperCase() ==
                                  correctAnswer.toUpperCase();

                        // Item label
                        String itemLabel = isFlowchartType
                            ? 'Step $itemNum'
                            : (answer.answerText.isNotEmpty
                                  ? answer.answerText
                                  : 'Item $itemNum');

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              // Item number
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: itemCorrect
                                      ? correct.withOpacity(0.1)
                                      : incorrect.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    '$itemNum',
                                    style: GoogleFonts.lexend(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: itemCorrect ? correct : incorrect,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Item label - show for both, with different text
                              Expanded(
                                child: Text(
                                  itemLabel,
                                  style: GoogleFonts.lexend(
                                    fontSize: 11,
                                    color: Colors.grey[800],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // User's Answer
                              if (isFlowchartType) ...[
                                Container(
                                  width: 60,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: itemCorrect
                                        ? correct.withOpacity(0.1)
                                        : incorrect.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: itemCorrect
                                          ? correct.withOpacity(0.3)
                                          : incorrect.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    userAnswer,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lexend(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: itemCorrect ? correct : incorrect,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 80,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: correct.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: correct.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    correctAnswer,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lexend(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: correct,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ] else ...[
                                // Matching - fixed width columns
                                Container(
                                  width: 45,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: itemCorrect
                                        ? correct.withOpacity(0.1)
                                        : incorrect.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: itemCorrect
                                          ? correct.withOpacity(0.3)
                                          : incorrect.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    userAnswer,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lexend(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: itemCorrect ? correct : incorrect,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 45,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: correct.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: correct.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    correctAnswer,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.lexend(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: correct,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                      // AI Explanation Section - Always show
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  size: 18,
                                  color: Colors.blue[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Explanation',
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Parse explanations from result (format: A:Item1:explanation|||B:Item2:explanation)
                            ...(() {
                              String? combinedExplanation =
                                  questionResult.explanation;
                              if (combinedExplanation == null ||
                                  combinedExplanation.isEmpty) {
                                return [
                                  Text(
                                    'No explanation available',
                                    style: GoogleFonts.lexend(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ];
                              }

                              // Split by ||| separator
                              List<String> explanationParts =
                                  combinedExplanation.split('|||');
                              return explanationParts.map((part) {
                                // Each part format: A:ItemName:Explanation
                                List<String> segments = part.split(':');
                                String optionLetter = segments.isNotEmpty
                                    ? segments[0]
                                    : '?';
                                String itemName = segments.length > 1
                                    ? segments[1]
                                    : '';
                                String explanation = segments.length > 2
                                    ? segments.sublist(2).join(':')
                                    : 'No explanation';

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: correct.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            optionLetter,
                                            style: GoogleFonts.lexend(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: correct,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              itemName,
                                              style: GoogleFonts.lexend(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              explanation,
                                              style: GoogleFonts.lexend(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList();
                            })(),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else ...[
            // MCQ Result
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnswerRow(
                    'Your Answer',
                    questionResult.userAnswer,
                    isCorrect ? correct : incorrect,
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(height: 8),
                    _buildAnswerRow(
                      'Correct Answer',
                      questionResult.correctAnswer,
                      correct,
                    ),
                  ],
                  // Explanation
                  if (questionResult.explanation != null &&
                      questionResult.explanation!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 18,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Explanation',
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  questionResult.explanation!,
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerRow(String label, String answer, Color color) {
    // Extract only the letter (A, B, C, D) if answer follows pattern like "A. text" or full text
    String displayAnswer = answer;
    if (answer.length >= 2 && answer[1] == '.') {
      // Answer starts with "A.", "B.", etc - extract just the letter
      displayAnswer = answer[0];
    } else if (answer.length == 1 && RegExp(r'^[A-D]$').hasMatch(answer)) {
      // Already just a letter
      displayAnswer = answer;
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey[600]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            displayAnswer,
            style: GoogleFonts.lexend(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return const Color(0xFF10B981);
      case 'Medium':
        return const Color(0xFFF59E0B);
      case 'Hard':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
