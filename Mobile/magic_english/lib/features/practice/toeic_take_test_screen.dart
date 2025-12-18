import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF059669); // Teal for TOEIC
    const neutral = Color(0xFFE0E0E0);

    final currentQuestion = widget.test.questions[_currentQuestionIndex];
    final selectedAnswerId = _selectedAnswers[currentQuestion.id];

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
                    onTap: () => _showExitDialog(),
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.test.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
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
                                color: const Color(0xFF333333),
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
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(_duration),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            if (currentQuestion.audioUrl != null &&
                                currentQuestion.audioUrl!.isNotEmpty)
                              Text(
                                'Listen carefully to answer the question',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Passage (if exists) - Only show for Reading sections, hide for Listening
                    if (currentQuestion.passage != null &&
                        currentQuestion.passage!.isNotEmpty &&
                        !_hasListeningAudio()) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
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
                                color: const Color(0xFF333333),
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
                        color: const Color(0xFF333333),
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
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? primary : Colors.grey[300]!,
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
                                        : Colors.grey[200],
                                  ),
                                  child: Center(
                                    child: Text(
                                      answer.answerOption,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[600],
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
                                      color: const Color(0xFF333333),
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
                color: const Color(0xFFF9F9F9),
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
                        foregroundColor: const Color(
                          0xFF333333,
                        ).withOpacity(0.8),
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
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              'Your progress will not be saved. Are you sure you want to exit?',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
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
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
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
      ),
    );
  }

  Future<void> _submitTest() async {
    if (_selectedAnswers.length < widget.test.questions.length) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Incomplete Test',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'You have ${widget.test.questions.length - _selectedAnswers.length} unanswered questions. Submit anyway?',
            style: GoogleFonts.plusJakartaSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey[600],
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
                  color: const Color(0xFF059669),
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
