import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/data/models/ielts/ielts_test.dart';
import 'package:magic_enlish/data/services/ielts_service.dart';
import 'package:magic_enlish/features/practice/ielts_result_screen.dart';
import 'package:magic_enlish/core/widgets/ielts_questions/ielts_chart_widget.dart';
import 'package:magic_enlish/core/widgets/ielts_questions/ielts_questions.dart';
import 'package:magic_enlish/core/utils/backend_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class IELTSTakeTestScreen extends StatefulWidget {
  final IELTSTest test;
  final IELTSTestHistory history;

  const IELTSTakeTestScreen({
    super.key,
    required this.test,
    required this.history,
  });

  @override
  State<IELTSTakeTestScreen> createState() => _IELTSTakeTestScreenState();
}

class _IELTSTakeTestScreenState extends State<IELTSTakeTestScreen> {
  final IELTSService _ieltsService = IELTSService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _currentQuestionIndex = 0;
  final Map<int, Set<int>> _selectedAnswers =
      {}; // questionId -> Set of answer IDs (for MCQ multi-select)
  final Map<int, String> _essayAnswers =
      {}; // questionId -> essay text (for Writing)
  final TextEditingController _essayController = TextEditingController();
  bool _isSubmitting = false;
  final int _startTime = DateTime.now().millisecondsSinceEpoch;

  // Answers for different question types
  final Map<int, Map<int, String>> _formAnswers =
      {}; // questionId -> {blankIndex -> answer}
  final Map<int, Map<int, String>> _matchingAnswers =
      {}; // questionId -> {itemIndex -> option}
  final Map<int, Map<int, String>> _sentenceAnswers =
      {}; // questionId -> {sentenceIndex -> answer}
  final Map<int, Map<int, String>> _flowchartAnswers =
      {}; // questionId -> {stepIndex -> answer}

  // Audio player state
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.release();
    _audioPlayer.dispose();
    _essayController.dispose();
    super.dispose();
  }

  /// Reset audio player state when switching questions
  Future<void> _resetAudio() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.release();
    } catch (e) {
      debugPrint('Audio reset error: $e');
    }
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _isLoadingAudio = false;
        _duration = Duration.zero;
        _position = Duration.zero;
      });
    }
  }

  bool _isLoadingAudio = false;

  Future<void> _playAudio(String audioUrl) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        return;
      }

      // Show loading state
      setState(() {
        _isLoadingAudio = true;
      });

      // Stop any previous audio
      await _audioPlayer.stop();

      // Build full URL and encode properly
      String fullUrl = BackendUtils.getFullUrl(audioUrl);
      String encodedUrl = fullUrl.replaceAll('+', '%20');
      debugPrint('Fetching audio from: $encodedUrl');

      // Fetch audio bytes with http (better timeout control)
      final uri = Uri.parse(encodedUrl);
      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw Exception('Audio request timed out. Please try again.');
            },
          );

      if (response.statusCode == 200) {
        final audioBytes = response.bodyBytes;
        debugPrint(
          'Audio fetched successfully, size: ${audioBytes.length} bytes',
        );

        if (audioBytes.length < 100) {
          throw Exception('Invalid audio response');
        }

        // Play from bytes
        await _audioPlayer.play(BytesSource(audioBytes));
      } else {
        throw Exception('Failed to load audio: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Audio Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceAll('Exception:', '').trim()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  int _getWordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  /// Count total answered questions across all question types
  int _getAnsweredCount() {
    int count = 0;

    for (var question in widget.test.questions) {
      final questionType = question.questionType ?? 'multiple_choice';
      final questionId = question.id;

      switch (questionType) {
        case 'form_completion':
          // Check if any form field answered for this question
          if (_formAnswers.containsKey(questionId) &&
              _formAnswers[questionId]!.values.any((v) => v.isNotEmpty)) {
            count++;
          }
          break;
        case 'matching':
          if (_matchingAnswers.containsKey(questionId) &&
              _matchingAnswers[questionId]!.isNotEmpty) {
            count++;
          }
          break;
        case 'sentence_completion':
          if (_sentenceAnswers.containsKey(questionId) &&
              _sentenceAnswers[questionId]!.values.any((v) => v.isNotEmpty)) {
            count++;
          }
          break;
        case 'flowchart':
          if (_flowchartAnswers.containsKey(questionId) &&
              _flowchartAnswers[questionId]!.values.any((v) => v.isNotEmpty)) {
            count++;
          }
          break;
        case 'multiple_choice':
        default:
          if (_selectedAnswers.containsKey(questionId) &&
              _selectedAnswers[questionId]!.isNotEmpty) {
            count++;
          }
          break;
      }
    }

    // Also count essay if writing test
    if (widget.test.skill == 'Writing' &&
        _essayController.text.trim().isNotEmpty) {
      count = 1; // Writing has only 1 question
    }

    return count;
  }

  /// Build appropriate widget based on question type
  Widget _buildQuestionWidget(IELTSQuestion question, Color primary) {
    final questionType = question.questionType ?? 'multiple_choice';

    switch (questionType) {
      case 'form_completion':
        // Initialize form answers if not exists
        _formAnswers.putIfAbsent(question.id, () => {});
        // For form completion: questionText is the field label (e.g., "Customer name:")
        // User types answer, correct answer is hidden (used only for grading)
        return FormCompletionWidget(
          formTitle: 'Complete the form based on what you hear:',
          blanks: [question.questionText], // Field label from question
          userAnswers: _formAnswers[question.id] ?? {},
          onAnswerChanged: (index, value) {
            setState(() {
              _formAnswers[question.id]![index] = value;
            });
          },
        );

      case 'matching':
        _matchingAnswers.putIfAbsent(question.id, () => {});
        // IELTS Matching format:
        // - Options (lettered A-D): Answer choices
        // - Items: Dynamic from AI (Student 1, Monday, Library, etc.)

        // Items: Use answerText from AI which contains the item name
        final items = question.answers.asMap().entries.map((e) {
          // answerText contains item name (e.g., "Student 1", "Monday", "Library")
          String itemText = e.value.answerText.isNotEmpty
              ? e.value.answerText
              : 'Item ${e.key + 1}';
          return MatchItem(id: e.value.id, text: itemText);
        }).toList();

        // Parse options from questionText (after "Options:")
        // Format: "Match each... Options: 1. Lack of experience, 2. Time pressure..."
        final optionLabels = <String>[];
        final questionParts = question.questionText.split('Options:');
        if (questionParts.length > 1) {
          final optionsPart = questionParts[1].trim();
          final optionsList = optionsPart.split(RegExp(r',\s*'));
          for (var opt in optionsList) {
            final trimmed = opt.trim();
            if (trimmed.isNotEmpty) {
              optionLabels.add(trimmed);
            }
          }
        }

        // Fallback: use answerOption + answerText as options
        if (optionLabels.isEmpty) {
          final seenOptions = <String>{};
          for (var a in question.answers) {
            if (!seenOptions.contains(a.answerOption)) {
              seenOptions.add(a.answerOption);
              if (a.answerText.isNotEmpty) {
                optionLabels.add('${a.answerOption}. ${a.answerText}');
              } else {
                optionLabels.add(a.answerOption);
              }
            }
          }
          optionLabels.sort();
        }

        // Get instruction text only (before "Options:")
        final instructionText = questionParts[0].trim();

        return MatchingWidget(
          questionText: instructionText.isNotEmpty
              ? instructionText
              : question.questionText,
          options: optionLabels.isEmpty
              ? ['1. Option A', '2. Option B', '3. Option C', '4. Option D']
              : optionLabels,
          items: items,
          selectedMatches: _matchingAnswers[question.id] ?? {},
          onMatchSelected: (index, value) {
            setState(() {
              _matchingAnswers[question.id]![index] = value;
            });
          },
        );

      case 'sentence_completion':
        _sentenceAnswers.putIfAbsent(question.id, () => {});
        // Parse sentence with blank from questionText
        final parts = question.questionText.split('________');
        final sentences = [
          SentenceBlank(
            id: question.id,
            textBefore: parts.isNotEmpty ? parts[0] : question.questionText,
            textAfter: parts.length > 1 ? parts[1] : '',
          ),
        ];
        return SentenceCompletionWidget(
          questionText: 'Complete the sentence:',
          questionNumber: question.questionNumber,
          sentences: sentences,
          userAnswers: _sentenceAnswers[question.id] ?? {},
          onAnswerChanged: (index, value) {
            setState(() {
              _sentenceAnswers[question.id]![index] = value;
            });
          },
        );

      case 'flowchart':
        _flowchartAnswers.putIfAbsent(question.id, () => {});

        // Extract instruction (first line before "Step 1:")
        String instruction = 'Complete the flow-chart:';
        String stepsText = question.questionText;

        // Check if there's a header/instruction before the steps
        final step1Index = question.questionText.indexOf('Step 1:');
        if (step1Index > 0) {
          instruction = question.questionText.substring(0, step1Index).trim();
          stepsText = question.questionText.substring(step1Index);
        }

        // Parse steps from remaining text (split by →)
        final stepTexts = stepsText
            .split('→')
            .where((s) => s.trim().isNotEmpty)
            .toList();
        int blankIndex = 0; // Track blank index for answer mapping
        final steps = stepTexts.asMap().entries.map((e) {
          final hasBlank = e.value.contains('________');
          if (hasBlank) {
            final parts = e.value.split('________');
            final currentBlankIndex = blankIndex++;
            return FlowchartStep(
              stepNumber:
                  currentBlankIndex + 1, // Use blank number, not step number
              text: e.value,
              hasBlank: true,
              textBefore: parts[0].trim(),
              textAfter: parts.length > 1 ? parts[1].trim() : '',
            );
          }
          return FlowchartStep(
            stepNumber: e.key + 1,
            text: e.value.trim(),
            hasBlank: false,
          );
        }).toList();

        return FlowchartWidget(
          questionText: instruction,
          questionNumber: question.questionNumber,
          steps: steps,
          userAnswers: _flowchartAnswers[question.id] ?? {},
          onAnswerChanged: (index, value) {
            setState(() {
              _flowchartAnswers[question.id]![index] = value;
            });
          },
        );

      case 'multiple_choice':
      default:
        // Default MCQ widget
        // Get set of selected indices from answer IDs
        final selectedAnswerIds = _selectedAnswers[question.id] ?? <int>{};
        final selectedIndicesSet = <int>{};
        for (int i = 0; i < question.answers.length; i++) {
          if (selectedAnswerIds.contains(question.answers[i].id)) {
            selectedIndicesSet.add(i);
          }
        }

        return MultipleChoiceWidget(
          questionText: question.questionText,
          options: question.answers
              .map(
                (a) => AnswerOption(
                  label: a.answerOption,
                  text: a.answerText,
                  id: a.id,
                ),
              )
              .toList(),
          selectedIndices: selectedIndicesSet,
          onOptionToggled: (index) {
            setState(() {
              final answerId = question.answers[index].id;
              _selectedAnswers.putIfAbsent(question.id, () => <int>{});
              if (_selectedAnswers[question.id]!.contains(answerId)) {
                _selectedAnswers[question.id]!.remove(answerId);
              } else {
                _selectedAnswers[question.id]!.add(answerId);
              }
            });
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF4A90E2);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final neutral = isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0);
    final background = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF9F9F9);
    final textPrimary = isDark ? Colors.white : const Color(0xFF333333);
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey[600];
    final containerBg = isDark ? const Color(0xFF1E1E1E) : Colors.grey[100];
    final containerBorder = isDark ? Colors.grey.shade800 : Colors.grey[300];

    final currentQuestion = widget.test.questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              decoration: BoxDecoration(
                color: background,
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
                    onTap: () => _showExitDialog(),
                    child: Container(
                      width: 35,
                      height: 35,
                      alignment: Alignment.center,
                      child: Icon(Icons.close, size: 28, color: textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.test.title,
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(width: 35),
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
                              'Question ${_currentQuestionIndex + 1} of ${widget.test.questions.length}',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              '${_getAnsweredCount()}/${widget.test.questions.length} answered',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                color: textSecondary,
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
                                  widget.test.questions.length,
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

                    // Audio Player (for Listening skill)
                    if (widget.test.skill == 'Listening') ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary.withOpacity(0.1),
                              primary.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.headphones,
                                  color: primary,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Listening Audio',
                                  style: GoogleFonts.lexend(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Play/Pause Button
                            GestureDetector(
                              onTap: _isLoadingAudio
                                  ? null
                                  : currentQuestion.audioUrl != null &&
                                        currentQuestion.audioUrl!.isNotEmpty
                                  ? () => _playAudio(currentQuestion.audioUrl!)
                                  : () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Audio is being generated...',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: _isLoadingAudio
                                      ? Colors.grey
                                      : primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _isLoadingAudio
                                    ? const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Icon(
                                        _isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Progress Bar
                            Column(
                              children: [
                                SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: primary,
                                    inactiveTrackColor: Colors.grey[300],
                                    thumbColor: primary,
                                    overlayColor: primary.withOpacity(0.2),
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                  ),
                                  child: Slider(
                                    min: 0,
                                    max: _duration.inSeconds.toDouble() > 0
                                        ? _duration.inSeconds.toDouble()
                                        : 1.0,
                                    value: _position.inSeconds.toDouble().clamp(
                                      0.0,
                                      _duration.inSeconds.toDouble() > 0
                                          ? _duration.inSeconds.toDouble()
                                          : 1.0,
                                    ),
                                    onChanged: (value) async {
                                      if (_duration.inSeconds > 0) {
                                        await _audioPlayer.seek(
                                          Duration(seconds: value.toInt()),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(_position),
                                        style: GoogleFonts.lexend(
                                          fontSize: 12,
                                          color: textSecondary,
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(_duration),
                                        style: GoogleFonts.lexend(
                                          fontSize: 12,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Hint Text
                            if (currentQuestion.audioUrl != null &&
                                currentQuestion.audioUrl!.isNotEmpty)
                              Text(
                                'Listen carefully to answer the question',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            else
                              Text(
                                'Audio URL: ${currentQuestion.audioUrl ?? "No audio available"}',
                                style: GoogleFonts.lexend(
                                  fontSize: 11,
                                  color: Colors.red[600],
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Passage (for Reading skill)
                    if (widget.test.skill == 'Reading' &&
                        currentQuestion.passage != null &&
                        currentQuestion.passage!.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: containerBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: containerBorder!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.article, color: primary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Reading Passage',
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentQuestion.passage!,
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                color: textPrimary,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Question - only show for multiple_choice (other widgets show it internally)
                    if ((currentQuestion.questionType ?? 'multiple_choice') ==
                        'multiple_choice') ...[
                      Text(
                        currentQuestion.questionText,
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Conditional: Essay input for Writing OR MCQ options for other skills
                    if (currentQuestion.questionType == 'essay') ...[
                      // Task 1: Display Chart if available
                      if (currentQuestion.chartData != null) ...[
                        IELTSChartWidget(chartData: currentQuestion.chartData!),
                        const SizedBox(height: 16),
                      ],

                      // Writing Instructions (Separate Card)
                      if (currentQuestion.passage != null &&
                          currentQuestion.passage!.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Instructions',
                                    style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                currentQuestion.passage!.replaceAll(
                                  '\\n',
                                  '\n',
                                ),
                                style: GoogleFonts.lexend(
                                  fontSize: 13,
                                  color: textSecondary,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Writing Essay Input (Separate Card)
                      Container(
                        decoration: BoxDecoration(
                          color: containerBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: containerBorder!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2C2C2C)
                                    : Colors.grey[100],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_note,
                                    size: 20,
                                    color: textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Your Essay',
                                    style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Essay Text Area
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: TextField(
                                controller: _essayController,
                                maxLines: 15,
                                onChanged: (value) {
                                  _essayAnswers[currentQuestion.id] = value;
                                  setState(() {}); // Update word count
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      'Start writing your essay here...\n\nMinimum ${currentQuestion.minWords ?? 150} words required.',
                                  hintStyle: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  height: 1.7,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            // Word Counter Footer
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _getWordCount(_essayController.text) >=
                                        (currentQuestion.minWords ?? 150)
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _getWordCount(_essayController.text) >=
                                                (currentQuestion.minWords ??
                                                    150)
                                            ? Icons.check_circle
                                            : Icons.warning_amber_rounded,
                                        size: 18,
                                        color:
                                            _getWordCount(
                                                  _essayController.text,
                                                ) >=
                                                (currentQuestion.minWords ??
                                                    150)
                                            ? Colors.green[600]
                                            : Colors.orange[600],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${_getWordCount(_essayController.text)} words',
                                        style: GoogleFonts.lexend(
                                          fontSize: 13,
                                          color:
                                              _getWordCount(
                                                    _essayController.text,
                                                  ) >=
                                                  (currentQuestion.minWords ??
                                                      150)
                                              ? Colors.green[700]
                                              : Colors.orange[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Minimum: ${currentQuestion.minWords ?? 150} words',
                                    style: GoogleFonts.lexend(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Validation message
                      if (_essayController.text.trim().isEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 16,
                                color: Colors.red[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Please write your essay before submitting.',
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (_getWordCount(_essayController.text) <
                          (currentQuestion.minWords ?? 150)) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Your essay needs ${(currentQuestion.minWords ?? 150) - _getWordCount(_essayController.text)} more words to meet the minimum requirement.',
                                  style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ] else ...[
                      // Render question based on type (MCQ, Form Completion, Matching, etc.)
                      _buildQuestionWidget(currentQuestion, primary),
                    ],

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Container(
              decoration: BoxDecoration(
                color: background,
                border: Border(
                  top: BorderSide(color: neutral.withOpacity(0.5), width: 1),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Back Button
                  if (_currentQuestionIndex > 0)
                    TextButton.icon(
                      onPressed: () {
                        _resetAudio();
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      icon: const Icon(Icons.arrow_back, size: 20),
                      label: Text(
                        'Back',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: textPrimary.withOpacity(0.8),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Next/Submit Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              if (_currentQuestionIndex <
                                  widget.test.questions.length - 1) {
                                // Next question
                                _resetAudio();
                                setState(() {
                                  _currentQuestionIndex++;
                                });
                              } else {
                                // Submit test
                                _submitTest();
                              }
                            },
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
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              _currentQuestionIndex <
                                      widget.test.questions.length - 1
                                  ? 'Next'
                                  : 'Submit Test',
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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

  void _showExitDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade600,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              'Exit Test?',
              style: GoogleFonts.lexend(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              'Your progress will be lost if you exit now. Are you sure?',
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F0F0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue Test',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF333333),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Exit test
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Exit',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitTest() async {
    // Check if all questions are answered
    bool allAnswered = true;
    String missingMessage = '';

    for (var question in widget.test.questions) {
      if (question.questionType == 'essay') {
        // For essay questions, check if there's text
        final essayText = _essayAnswers[question.id] ?? '';
        final wordCount = _getWordCount(essayText);
        if (wordCount < 10) {
          // At least 10 words as a sanity check
          allAnswered = false;
          missingMessage = 'Please write your essay before submitting';
          break;
        }
      } else {
        // Check based on question type
        final questionType = question.questionType ?? 'multiple_choice';
        bool hasAnswer = false;

        switch (questionType) {
          case 'form_completion':
            hasAnswer =
                _formAnswers.containsKey(question.id) &&
                _formAnswers[question.id]!.values.any((v) => v.isNotEmpty);
            break;
          case 'matching':
            hasAnswer =
                _matchingAnswers.containsKey(question.id) &&
                _matchingAnswers[question.id]!.isNotEmpty;
            break;
          case 'sentence_completion':
            hasAnswer =
                _sentenceAnswers.containsKey(question.id) &&
                _sentenceAnswers[question.id]!.values.any((v) => v.isNotEmpty);
            break;
          case 'flowchart':
            hasAnswer =
                _flowchartAnswers.containsKey(question.id) &&
                _flowchartAnswers[question.id]!.values.any((v) => v.isNotEmpty);
            break;
          case 'multiple_choice':
          default:
            hasAnswer =
                _selectedAnswers.containsKey(question.id) &&
                _selectedAnswers[question.id]!.isNotEmpty;
            break;
        }

        if (!hasAnswer) {
          allAnswered = false;
          missingMessage = 'Please answer all questions before submitting';
          break;
        }
      }
    }

    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(missingMessage, style: GoogleFonts.lexend()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Calculate time spent
      int timeSpent =
          ((DateTime.now().millisecondsSinceEpoch - _startTime) / 1000).round();

      // Prepare answers
      List<Map<String, dynamic>> answers = [];
      for (var question in widget.test.questions) {
        final questionType = question.questionType ?? 'multiple_choice';

        if (questionType == 'essay') {
          // For essay questions, send the essay text
          answers.add({
            'questionId': question.id,
            'answerText': _essayAnswers[question.id] ?? '',
          });
        } else if (questionType == 'form_completion') {
          // For form completion, join all answers into a single string
          final formAnswers = _formAnswers[question.id] ?? {};
          final answerText = formAnswers.values.join(', ');
          answers.add({'questionId': question.id, 'answerText': answerText});
        } else if (questionType == 'sentence_completion') {
          // For sentence completion
          final sentenceAnswers = _sentenceAnswers[question.id] ?? {};
          final answerText = sentenceAnswers.values.join(', ');
          answers.add({'questionId': question.id, 'answerText': answerText});
        } else if (questionType == 'flowchart') {
          // For flowchart, send each blank's answer with index
          final flowchartAnswers = _flowchartAnswers[question.id] ?? {};
          // Build answer text as "0:answer1,1:answer2,..." format (blankIndex:answer)
          final answerParts = <String>[];
          flowchartAnswers.forEach((blankIndex, answer) {
            answerParts.add('$blankIndex:$answer');
          });
          final answerText = answerParts.join(',');
          answers.add({'questionId': question.id, 'answerText': answerText});
        } else if (questionType == 'matching') {
          // For matching, send each student's selected option letter
          final matchingAnswers = _matchingAnswers[question.id] ?? {};
          // Build answer text as "0:A,1:B,2:C,3:D" format (studentIndex:letter)
          final answerParts = <String>[];
          matchingAnswers.forEach((studentIndex, selectedOption) {
            // Extract letter from option (e.g., "A. Some text" -> "A")
            String letter = selectedOption;
            if (selectedOption.length >= 2 && selectedOption[1] == '.') {
              letter = selectedOption[0];
            }
            answerParts.add('$studentIndex:$letter');
          });
          answers.add({
            'questionId': question.id,
            'answerText': answerParts.join(','),
          });
        } else {
          // For MCQ, send all selected answer IDs joined by comma
          final selectedIds = _selectedAnswers[question.id] ?? <int>{};
          answers.add({
            'questionId': question.id,
            'selectedAnswerIds': selectedIds.toList(),
          });
        }
      }

      // Submit test
      final result = await _ieltsService.submitTest(
        historyId: widget.history.id,
        answers: answers,
        timeSpentSeconds: timeSpent,
      );

      if (!mounted) return;

      // Navigate to result screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              IELTSResultScreen(result: result, test: widget.test),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to submit test: ${e.toString()}',
            style: GoogleFonts.lexend(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
