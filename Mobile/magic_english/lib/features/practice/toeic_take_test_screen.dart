import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// cached_network_image import removed - image feature disabled
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../data/models/toeic/toeic_test.dart';
import '../../data/services/toeic_service.dart';
import 'package:magic_enlish/core/utils/backend_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'toeic_result_screen.dart';

class ToeicTakeTestScreen extends StatefulWidget {
  final ToeicTest test;
  final int historyId;

  const ToeicTakeTestScreen({
    super.key,
    required this.test,
    required this.historyId,
  });

  @override
  State<ToeicTakeTestScreen> createState() => _ToeicTakeTestScreenState();
}

class _ToeicTakeTestScreenState extends State<ToeicTakeTestScreen> {
  final ToeicService _toeicService = ToeicService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _currentQuestionIndex = 0;
  final Map<int, int?> _selectedAnswers = {}; // questionId -> answerId
  bool _isSubmitting = false;
  final int _startTime = DateTime.now().millisecondsSinceEpoch;

  // Audio player state
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    // Background load remaining images (first image already cached before entering)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _backgroundLoadRemainingImages();
    });
  }

  /// Background load all images except first (which was preloaded before entering test)
  /// Uses sequential loading with delay to avoid 429 rate limiting
  Future<void> _backgroundLoadRemainingImages() async {
    final questionsWithImages = widget.test.questions
        .where((q) => q.imageUrl != null && q.imageUrl!.isNotEmpty)
        .toList();

    if (questionsWithImages.length <= 1) return; // First image already cached

    // Skip first image (already cached), load the rest sequentially with delay
    final remainingQuestions = questionsWithImages.skip(1).toList();
    debugPrint(
      'Background loading ${remainingQuestions.length} remaining images (with delay)...',
    );

    for (int i = 0; i < remainingQuestions.length; i++) {
      final question = remainingQuestions[i];

      // Add delay between requests to avoid 429 rate limiting (2 seconds)
      if (i > 0) {
        await Future.delayed(const Duration(seconds: 2));
      }

      try {
        await DefaultCacheManager().downloadFile(question.imageUrl!);
        debugPrint('Background loaded: Question ${question.questionNumber}');
      } catch (e) {
        debugPrint('Failed to background load image: $e');
        // If rate limited (429), wait longer before next request
        if (e.toString().contains('429')) {
          await Future.delayed(const Duration(seconds: 5));
        }
      }
    }
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
    super.dispose();
  }

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

      setState(() {
        _isLoadingAudio = true;
      });

      await _audioPlayer.stop();

      // Build full URL and encode properly
      String fullUrl = BackendUtils.getFullUrl(audioUrl);
      String encodedUrl = fullUrl.replaceAll('+', '%20');
      debugPrint('Fetching audio from: $encodedUrl');

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

  bool _hasListeningAudio() {
    return widget.test.section.toLowerCase().contains('listening') ||
        widget.test.section.toLowerCase().contains('part 1') ||
        widget.test.section.toLowerCase().contains('part 2') ||
        widget.test.section.toLowerCase().contains('part 3') ||
        widget.test.section.toLowerCase().contains('part 4');
  }

  // Check if this is a Reading section test
  bool _isReadingSection() {
    return widget.test.section.toLowerCase().contains('reading') ||
        widget.test.section.toLowerCase().contains('part 5') ||
        widget.test.section.toLowerCase().contains('part 6') ||
        widget.test.section.toLowerCase().contains('part 7');
  }

  // Helper methods to determine TOEIC Listening Part type based on current question
  bool _isPart1Photographs(String? questionPart) {
    final part = questionPart?.toLowerCase() ?? '';
    final section = widget.test.section.toLowerCase();
    return part.contains('part 1') ||
        part.contains('photograph') ||
        section.contains('part 1') ||
        section.contains('photographs');
  }

  bool _isPart2QuestionResponse(String? questionPart) {
    final part = questionPart?.toLowerCase() ?? '';
    final section = widget.test.section.toLowerCase();
    return part.contains('part 2') ||
        part.contains('question') ||
        section.contains('part 2') ||
        section.contains('question & response');
  }

  bool _isPart3Conversations(String? questionPart) {
    final part = questionPart?.toLowerCase() ?? '';
    final section = widget.test.section.toLowerCase();
    return part.contains('part 3') ||
        part.contains('conversation') ||
        section.contains('part 3') ||
        section.contains('conversations');
  }

  bool _isPart4Talks(String? questionPart) {
    final part = questionPart?.toLowerCase() ?? '';
    final section = widget.test.section.toLowerCase();
    return part.contains('part 4') ||
        part.contains('talk') ||
        section.contains('part 4') ||
        section.contains('talks');
  }

  // Helper methods for TOEIC Reading Parts
  bool _isPart5IncompleteSentences(String? questionPart) {
    final part = questionPart?.toLowerCase() ?? '';
    final section = widget.test.section.toLowerCase();
    return part.contains('part 5') ||
        part.contains('incomplete') ||
        section.contains('part 5') ||
        section.contains('incomplete sentences');
  }

  bool _isPart6TextCompletion(String? questionPart) {
    final part = questionPart?.toLowerCase() ?? '';
    final section = widget.test.section.toLowerCase();
    return part.contains('part 6') ||
        part.contains('text completion') ||
        section.contains('part 6') ||
        section.contains('text completion');
  }

  bool _isPart7ReadingComprehension(String? questionPart) {
    final part = questionPart?.toLowerCase() ?? '';
    final section = widget.test.section.toLowerCase();
    return part.contains('part 7') ||
        part.contains('reading comprehension') ||
        section.contains('part 7') ||
        section.contains('reading comprehension');
  }

  String _getPartLabel(String? questionPart) {
    // Listening Parts
    if (_isPart1Photographs(questionPart)) return 'Part 1 - Photographs';
    if (_isPart2QuestionResponse(questionPart)) {
      return 'Part 2 - Question & Response';
    }
    if (_isPart3Conversations(questionPart)) return 'Part 3 - Conversations';
    if (_isPart4Talks(questionPart)) return 'Part 4 - Talks';
    // Reading Parts
    if (_isPart5IncompleteSentences(questionPart)) {
      return 'Part 5 - Incomplete Sentences';
    }
    if (_isPart6TextCompletion(questionPart)) return 'Part 6 - Text Completion';
    if (_isPart7ReadingComprehension(questionPart)) {
      return 'Part 7 - Reading Comprehension';
    }
    // Default
    if (_isReadingSection()) return 'Reading';
    return 'Listening';
  }

  String _getPartDescription(String? questionPart) {
    // Listening Parts
    if (_isPart1Photographs(questionPart)) {
      return 'Look at the photograph and choose the statement that best describes the picture.';
    }
    if (_isPart2QuestionResponse(questionPart)) {
      return 'Listen to the question and choose the best response.';
    }
    if (_isPart3Conversations(questionPart)) {
      return 'Listen to the conversation and answer the questions.';
    }
    if (_isPart4Talks(questionPart)) {
      return 'Listen to the talk and answer the questions.';
    }
    // Reading Parts
    if (_isPart5IncompleteSentences(questionPart)) {
      return 'Choose the word or phrase that best completes the sentence.';
    }
    if (_isPart6TextCompletion(questionPart)) {
      return 'Choose the word, phrase, or sentence that best completes the text.';
    }
    if (_isPart7ReadingComprehension(questionPart)) {
      return 'Read the passage and answer the questions.';
    }
    // Default
    if (_isReadingSection()) return 'Read carefully and answer the questions.';
    return 'Listen carefully and answer the questions.';
  }

  // Image placeholder removed - image feature disabled

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? const Color(0xFF4ADE80) : const Color(0xFF059669);
    final neutral = isDark ? Colors.grey[800]! : const Color(0xFFE0E0E0);
    final background = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF9F9F9);
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF333333);
    final textSecondary = isDark ? Colors.grey.shade400 : Colors.grey[600];
    final border = isDark ? Colors.grey.shade700 : Colors.grey[300]!;
    final blueColor = isDark ? Colors.blue.shade300 : const Color(0xFF2563EB);
    final blueBg = isDark
        ? Colors.blue.withOpacity(0.2)
        : const Color(0xFF2563EB).withOpacity(0.05);

    final currentQuestion = widget.test.questions[_currentQuestionIndex];
    final selectedAnswerId = _selectedAnswers[currentQuestion.id];

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
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
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
                      style: GoogleFonts.plusJakartaSans(
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
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: textPrimary,
                              ),
                            ),
                            Text(
                              '${_selectedAnswers.length}/${widget.test.questions.length} answered',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey[600],
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

                    // Audio Player (for Listening sections)
                    if (_hasListeningAudio()) ...[
                      // Part Label & Description
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getPartLabel(currentQuestion.part),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.black87
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getPartDescription(currentQuestion.part),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.grey.shade300
                                    : Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Audio Player Card
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
                                  style: GoogleFonts.plusJakartaSans(
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
                                        const SnackBar(
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
                                    ? Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                isDark
                                                    ? Colors.black87
                                                    : Colors.white,
                                              ),
                                        ),
                                      )
                                    : Icon(
                                        _isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: isDark
                                            ? Colors.black87
                                            : Colors.white,
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
                                    inactiveTrackColor: isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey[300],
                                    thumbColor: primary,
                                    overlayColor: primary.withOpacity(0.2),
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                  ),
                                  child: Slider(
                                    value: _position.inSeconds.toDouble(),
                                    max: _duration.inSeconds.toDouble() > 0
                                        ? _duration.inSeconds.toDouble()
                                        : 1.0,
                                    onChanged: (value) async {
                                      final position = Duration(
                                        seconds: value.toInt(),
                                      );
                                      await _audioPlayer.seek(position);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(_position),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: textSecondary,
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(_duration),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: textSecondary,
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
                      const SizedBox(height: 20),

                      // Part 1 - No image display (audio only)

                      // Part 2, 3, 4 - Just show "Listen carefully" message (no transcript shown during test)
                      // Transcripts will be shown in the result screen after completing the test
                    ],

                    // Passage (if exists) - Only show for Reading sections, hide for Listening
                    // Reading Part Label & Description (for Reading sections Part 5, 6, 7)
                    if (_isReadingSection() && !_hasListeningAudio()) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: blueBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: blueColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: blueColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getPartLabel(currentQuestion.part),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getPartDescription(currentQuestion.part),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Passage (if exists) - Only show for Part 6 and Part 7 (not Part 5)
                    if (currentQuestion.passage != null &&
                        currentQuestion.passage!.isNotEmpty &&
                        !_hasListeningAudio()) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2C)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.article, color: primary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Passage',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentQuestion.passage!,
                              style: GoogleFonts.plusJakartaSans(
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

                    // Question
                    Text(
                      currentQuestion.questionText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Answer Options
                    ...currentQuestion.answers.map((answer) {
                      final isSelected = selectedAnswerId == answer.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedAnswers[currentQuestion.id] = answer.id;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primary.withOpacity(0.1)
                                  : surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? primary : border,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? primary
                                        : (isDark
                                              ? Colors.grey[700]
                                              : Colors.grey[200]),
                                  ),
                                  child: Center(
                                    child: Text(
                                      answer.answerOption,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? (isDark
                                                  ? Colors.black
                                                  : Colors.white)
                                            : (isDark
                                                  ? Colors.grey[300]
                                                  : Colors.grey[600]),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    answer.answerText,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      color: textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
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
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: textPrimary.withOpacity(0.8),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              if (_currentQuestionIndex <
                                  widget.test.questions.length - 1) {
                                _resetAudio();
                                setState(() {
                                  _currentQuestionIndex++;
                                });
                              } else {
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
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? Colors.black87 : Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              _currentQuestionIndex <
                                      widget.test.questions.length - 1
                                  ? 'Next'
                                  : 'Submit Test',
                              style: GoogleFonts.plusJakartaSans(
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
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              // Message
              Text(
                'Your progress will not be saved. Are you sure you want to exit?',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey[600],
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
                        backgroundColor: isDark
                            ? Colors.grey.shade800
                            : const Color(0xFFF0F0F0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Continue Test',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF333333),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Exit test screen
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
                        style: GoogleFonts.plusJakartaSans(
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
        );
      },
    );
  }

  Future<void> _submitTest() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_selectedAnswers.length < widget.test.questions.length) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Incomplete Test',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            'You have ${widget.test.questions.length - _selectedAnswers.length} unanswered questions. Submit anyway?',
            style: GoogleFonts.plusJakartaSans(
              color: isDark ? Colors.grey.shade300 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  color: isDark ? Colors.grey.shade400 : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performSubmit();
              },
              child: Text(
                'Submit',
                style: GoogleFonts.plusJakartaSans(
                  color: isDark ? Colors.greenAccent : const Color(0xFF059669),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    await _performSubmit();
  }

  Future<void> _performSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final timeSpent =
          ((DateTime.now().millisecondsSinceEpoch - _startTime) / 1000).round();

      final answers = _selectedAnswers.entries
          .where((e) => e.value != null)
          .map((e) => {'questionId': e.key, 'selectedAnswerId': e.value!})
          .toList();

      final result = await _toeicService.submitTest(
        widget.historyId,
        answers,
        timeSpent,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ToeicResultScreen(result: result, test: widget.test),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit test: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
