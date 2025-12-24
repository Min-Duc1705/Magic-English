import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:magic_enlish/providers/vocabulary/vocabulary_provider.dart';
import 'package:magic_enlish/data/models/vocabulary/Vocabulary.dart';
import 'package:magic_enlish/data/services/pronunciation_service.dart';

class SpeakingPracticeScreen extends StatefulWidget {
  const SpeakingPracticeScreen({super.key});

  @override
  State<SpeakingPracticeScreen> createState() => _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState extends State<SpeakingPracticeScreen> {
  int _currentWordIndex = 0;
  bool _isRecording = false;
  bool _isAnalyzing = false;
  bool _shouldKeepListening = false; // Flag to control continuous listening
  bool _isRestarting = false; // Flag to prevent multiple concurrent restarts
  List<Vocabulary> _practiceWords = [];

  // Speech recognition - recreate instance for each session
  stt.SpeechToText _speech = stt.SpeechToText();
  String _selectedLocaleId = 'en_US';
  bool _speechAvailable = false;
  String _transcribedText = '';
  DateTime? _lastRecordingEndTime; // Track when last recording ended
  static const int _cooldownSeconds = 2; // Minimum seconds between recordings

  // Audio player for listening to word pronunciation
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;

  // Pronunciation service
  final PronunciationService _pronunciationService = PronunciationService();

  // Score tracking
  int _totalScore = 0;
  int _wordsCompleted = 0;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndInit();
    _loadPracticeWords();
  }

  Future<void> _checkPermissionAndInit() async {
    final status = await Permission.microphone.status;

    if (status.isDenied) {
      final result = await Permission.microphone.request();
      if (result.isGranted) {
        _initSpeech();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Microphone permission is required for speaking practice',
              ),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => openAppSettings(),
              ),
            ),
          );
        }
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Please enable microphone permission in Settings',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Open Settings',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    } else if (status.isGranted) {
      _initSpeech();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _audioPlayer.stop();
    _audioPlayer.release();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
        // CONTINUOUS MODE: Auto-restart if speech auto-stops but user hasn't pressed Stop
        if (status == 'done' || status == 'notListening') {
          if (mounted && _shouldKeepListening) {
            // Auto-restart listening - user hasn't pressed Stop yet
            debugPrint('Auto-restarting speech recognition...');
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted && _shouldKeepListening) {
                _restartListening();
              }
            });
          } else if (mounted && _isRecording) {
            // User pressed Stop or not listening anymore
            setState(() => _isRecording = false);
          }
        }
      },
      onError: (error) {
        debugPrint('Speech error: ${error.errorMsg}');

        // error_no_match and error_speech_timeout are expected during silence
        // Don't restart on these - the done/notListening status will handle restart
        final isExpectedError =
            error.errorMsg == 'error_no_match' ||
            error.errorMsg == 'error_speech_timeout';

        if (isExpectedError && _shouldKeepListening) {
          // Ignore expected errors during continuous listening - restart will be handled by status callback
          debugPrint('Ignoring expected error during continuous listening');
          return;
        }

        if (mounted && _shouldKeepListening && !isExpectedError) {
          // Auto-restart on unexpected errors only
          debugPrint('Restarting after unexpected error...');
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _shouldKeepListening) {
              _restartListening();
            }
          });
        } else if (mounted && !_shouldKeepListening) {
          setState(() => _isRecording = false);

          String userMessage;
          if (error.errorMsg == 'error_speech_timeout') {
            userMessage =
                'No speech detected. Please speak louder or closer to the microphone.';
          } else if (error.errorMsg == 'error_no_match') {
            userMessage =
                'Could not understand. Please try speaking in English.';
          } else if (error.errorMsg == 'error_busy') {
            userMessage = 'Speech recognition is busy. Please try again.';
          } else if (error.errorMsg.contains('permission')) {
            userMessage =
                'Microphone permission denied. Please enable it in settings.';
          } else {
            userMessage = 'Speech recognition error. Please try again.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userMessage),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      },
    );

    if (_speechAvailable) {
      // Get available locales and find best English locale
      final locales = await _speech.locales();
      debugPrint(
        'Available locales: ${locales.map((l) => l.localeId).toList()}',
      );

      // Try to find English locale in order of preference
      final preferredLocales = ['en_US', 'en_GB', 'en_AU', 'en_IN', 'en'];
      for (final preferred in preferredLocales) {
        final match = locales
            .where((l) => l.localeId.startsWith(preferred))
            .toList();
        if (match.isNotEmpty) {
          _selectedLocaleId = match.first.localeId;
          debugPrint('Selected locale: $_selectedLocaleId');
          break;
        }
      }

      // If no English locale found, try to use any available locale
      if (_selectedLocaleId == 'en_US' && locales.isNotEmpty) {
        final englishLocales = locales
            .where((l) => l.localeId.toLowerCase().contains('en'))
            .toList();
        if (englishLocales.isNotEmpty) {
          _selectedLocaleId = englishLocales.first.localeId;
          debugPrint('Fallback to locale: $_selectedLocaleId');
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Speech recognition not available. Please check microphone permissions.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }

    setState(() {});
  }

  Future<void> _loadPracticeWords() async {
    final provider = Provider.of<VocabularyProvider>(context, listen: false);
    await provider.loadVocabularies();

    if (provider.vocabularies.isEmpty) return;

    setState(() {
      _practiceWords = (provider.vocabularies.toList()..shuffle())
          .take(10)
          .toList();
    });
  }

  Future<void> _playWordAudio() async {
    if (_practiceWords.isEmpty) return;

    final currentWord = _practiceWords[_currentWordIndex];
    if (currentWord.audioUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No audio available for this word'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isPlayingAudio = true);

    try {
      await _audioPlayer.play(UrlSource(currentWord.audioUrl));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() => _isPlayingAudio = false);
        }
      });
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        setState(() => _isPlayingAudio = false);
      }
    }
  }

  Future<bool> _showPermissionExplanationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.mic, color: const Color(0xFF9B59B6), size: 28),
                const SizedBox(width: 12),
                const Text('Microphone Permission'),
              ],
            ),
            content: const Text(
              'To practice speaking, we need access to your microphone to record and analyze your pronunciation.\n\nWould you like to enable microphone access?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Not Now'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B59B6),
                ),
                child: const Text(
                  'Allow',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.settings, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Text('Permission Required'),
          ],
        ),
        content: const Text(
          'Microphone permission was previously denied.\n\nTo use speaking practice, please go to Settings and enable microphone access for this app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text(
              'Open Settings',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _startRecording() async {
    // Kiểm tra quyền trước khi bắt đầu
    final status = await Permission.microphone.status;

    if (status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionSettingsDialog();
      }
      return;
    }

    if (!status.isGranted) {
      final shouldRequest = await _showPermissionExplanationDialog();
      if (!shouldRequest) return;

      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        if (result.isPermanentlyDenied && mounted) {
          _showPermissionSettingsDialog();
        }
        return;
      }
    }

    // Check cooldown - BEFORE setting _isRecording to true
    if (_lastRecordingEndTime != null) {
      final timeSinceLastRecording = DateTime.now().difference(
        _lastRecordingEndTime!,
      );
      if (timeSinceLastRecording.inSeconds < _cooldownSeconds) {
        final waitTime = _cooldownSeconds - timeSinceLastRecording.inSeconds;
        debugPrint('Waiting $waitTime seconds before next recording...');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please wait $waitTime seconds...'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 1),
            ),
          );
        }
        await Future.delayed(Duration(seconds: waitTime));
      }
    }

    try {
      // CRITICAL FIX: Stop and cancel any existing session
      try {
        await _speech.stop();
        await _speech.cancel();
      } catch (e) {
        debugPrint('Cleanup error (ignored): $e');
      }

      // Wait for Android to release microphone resources
      await Future.delayed(const Duration(milliseconds: 300));

      // CRITICAL FIX: ALWAYS create a new SpeechToText instance
      // Android's speech recognizer doesn't reset properly after first use
      _speech = stt.SpeechToText();
      await Future.delayed(const Duration(milliseconds: 200));

      // Initialize the NEW instance with fresh callbacks
      final available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
          // CONTINUOUS MODE: Auto-restart if speech auto-stops but user hasn't pressed Stop
          if (status == 'done' || status == 'notListening') {
            _lastRecordingEndTime = DateTime.now();
            if (mounted && _shouldKeepListening) {
              // Auto-restart listening - user hasn't pressed Stop yet
              debugPrint('Auto-restarting speech recognition...');
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted && _shouldKeepListening) {
                  _restartListening();
                }
              });
            } else {
              // User pressed Stop or not listening anymore
              setState(() => _isRecording = false);
            }
          }
        },
        onError: (error) {
          debugPrint('Speech error: ${error.errorMsg}');
          _lastRecordingEndTime = DateTime.now();

          // error_no_match and error_speech_timeout are expected during silence
          final isExpectedError =
              error.errorMsg == 'error_no_match' ||
              error.errorMsg == 'error_speech_timeout';

          if (isExpectedError && _shouldKeepListening) {
            debugPrint('Ignoring expected error during continuous listening');
            return;
          }

          if (mounted && _shouldKeepListening && !isExpectedError) {
            debugPrint('Restarting after unexpected error...');
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && _shouldKeepListening) {
                _restartListening();
              }
            });
          } else if (mounted && !_shouldKeepListening) {
            setState(() => _isRecording = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Speech error. Please try again.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
      );

      if (!available) {
        throw Exception('Speech recognition not available');
      }

      // Set recording state and enable continuous listening
      _shouldKeepListening = true;
      setState(() {
        _isRecording = true;
        _transcribedText = '';
      });

      // Start listening with locale
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _transcribedText = result.recognizedWords;
            });
            debugPrint('Speech recognized: ${result.recognizedWords}');
          }
        },
        localeId: _selectedLocaleId,
        listenFor: const Duration(seconds: 60), // Listen for up to 60 seconds
        pauseFor: const Duration(
          seconds: 10,
        ), // Wait 10 seconds of silence before stopping
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      );

      debugPrint('Speech listening started with locale: $_selectedLocaleId');
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _lastRecordingEndTime = DateTime.now();
      _shouldKeepListening = false;

      if (mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not start recording. Please try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Restart listening without reinitializing speech (for continuous mode)
  Future<void> _restartListening() async {
    // Prevent multiple concurrent restarts
    if (_isRestarting) {
      debugPrint('Already restarting, skipping...');
      return;
    }

    if (!_shouldKeepListening || !mounted) {
      debugPrint(
        'Skipping restart - shouldKeepListening=$_shouldKeepListening, mounted=$mounted',
      );
      return;
    }

    _isRestarting = true;

    try {
      debugPrint('Attempting to restart speech listening...');

      // Wait longer for the previous session to fully close
      await Future.delayed(const Duration(milliseconds: 500));

      if (!_shouldKeepListening || !mounted) {
        _isRestarting = false;
        return;
      }

      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _transcribedText = result.recognizedWords;
            });
            debugPrint('Speech recognized: ${result.recognizedWords}');
          }
        },
        localeId: _selectedLocaleId,
        listenFor: const Duration(seconds: 60), // Listen for up to 60 seconds
        pauseFor: const Duration(
          seconds: 10,
        ), // Wait 10 seconds of silence before stopping
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      );
      debugPrint('Speech restarted successfully!');
    } catch (e) {
      debugPrint('Error restarting speech: $e');
      // Try again after a longer delay if still should keep listening
      if (_shouldKeepListening && mounted) {
        debugPrint('Will retry restart in 1 second...');
        await Future.delayed(const Duration(seconds: 1));
        if (_shouldKeepListening && mounted) {
          _isRestarting = false; // Reset before retry
          _restartListening(); // Retry
          return;
        }
      }
    }

    _isRestarting = false;
  }

  void _stopRecording() async {
    // IMPORTANT: Set flag FIRST to prevent auto-restart
    _shouldKeepListening = false;

    await _speech.stop();
    setState(() => _isRecording = false);

    // MANUAL MODE: This is the ONLY place that triggers AI grading
    if (_transcribedText.isNotEmpty) {
      _analyzeWithAI();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No speech detected. Please try again.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  Future<void> _analyzeWithAI() async {
    if (_transcribedText.isEmpty) return;

    final currentWord = _practiceWords[_currentWordIndex];

    setState(() => _isAnalyzing = true);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF9B59B6)),
            const SizedBox(height: 16),
            Text(
              'Analyzing your pronunciation...',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a few seconds',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );

    try {
      // Add timeout of 10 seconds
      final feedback = await _pronunciationService
          .analyzePronunciation(
            expectedWord: currentWord.word,
            transcribedText: _transcribedText,
            ipa: currentWord.ipa,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Analysis timeout - using basic scoring');
            },
          );

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showFeedbackDialog(feedback);
      }
    } catch (e) {
      debugPrint('Error analyzing pronunciation: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        // Fallback to basic comparison
        _showBasicFeedbackDialog();
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _showFeedbackDialog(PronunciationFeedback feedback) {
    final currentWord = _practiceWords[_currentWordIndex];

    // Update scores
    _totalScore += feedback.score;
    _wordsCompleted++;

    Color scoreColor;
    IconData scoreIcon;

    if (feedback.score >= 90) {
      scoreColor = Colors.green;
      scoreIcon = Icons.emoji_events;
    } else if (feedback.score >= 70) {
      scoreColor = Colors.lightGreen;
      scoreIcon = Icons.check_circle;
    } else if (feedback.score >= 50) {
      scoreColor = Colors.orange;
      scoreIcon = Icons.info;
    } else {
      scoreColor = Colors.red;
      scoreIcon = Icons.refresh;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(scoreIcon, color: scoreColor, size: 32),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                feedback.accuracy == 'excellent'
                    ? 'Excellent! 🎉'
                    : feedback.accuracy == 'good'
                    ? 'Good Job! 👏'
                    : feedback.accuracy == 'fair'
                    ? 'Nice Try! 💪'
                    : 'Keep Practicing! 📚',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Score Circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [scoreColor, scoreColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scoreColor.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${feedback.score}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Expected vs Transcribed
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check, color: Colors.green, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Expected: ',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            currentWord.word,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.mic,
                          color: const Color(0xFFF97316), // Orange
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'You said: ',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            feedback.transcribedText,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF97316), // Orange
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // AI Feedback
              Text(
                feedback.feedback,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),

              // Suggestions
              if (feedback.suggestions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.blue, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Tips:',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...feedback.suggestions.map(
                        (suggestion) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• ',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.blue,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: Colors.grey[700],
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
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _transcribedText = '';
              });
            },
            child: Text('Try Again', style: GoogleFonts.plusJakartaSans()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _transcribedText = '';
              });
              _nextWord();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316), // Orange
            ),
            child: Text(
              'Next Word',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showBasicFeedbackDialog() {
    final currentWord = _practiceWords[_currentWordIndex];
    final expectedLower = currentWord.word.toLowerCase();
    final transcribedLower = _transcribedText.toLowerCase();

    int score;
    String feedback;

    if (expectedLower == transcribedLower) {
      score = 100;
      feedback = 'Perfect pronunciation!';
    } else if (transcribedLower.contains(expectedLower) ||
        expectedLower.contains(transcribedLower)) {
      score = 75;
      feedback = 'Good! Very close to the correct pronunciation.';
    } else {
      score = 50;
      feedback = 'Keep practicing! Listen to the word again.';
    }

    _totalScore += score;
    _wordsCompleted++;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          score >= 90
              ? 'Excellent! 👏'
              : score >= 70
              ? 'Good Job! 👍'
              : 'Keep Trying! 💪',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              score >= 90
                  ? Icons.emoji_events
                  : score >= 70
                  ? Icons.check_circle
                  : Icons.refresh,
              color: score >= 90
                  ? Colors.amber
                  : score >= 70
                  ? Colors.green
                  : Colors.orange,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              feedback,
              style: GoogleFonts.plusJakartaSans(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Score: $score%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF9B59B6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You said: "$_transcribedText"',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _transcribedText = '';
              });
            },
            child: Text('Try Again', style: GoogleFonts.plusJakartaSans()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _transcribedText = '';
              });
              _nextWord();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B59B6),
            ),
            child: Text(
              'Next Word',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _nextWord() {
    if (_currentWordIndex < _practiceWords.length - 1) {
      setState(() {
        _currentWordIndex++;
        _transcribedText = '';
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final averageScore = _wordsCompleted > 0
        ? (_totalScore / _wordsCompleted).round()
        : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Practice Complete! 🎤',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF9B59B6),
                    const Color(0xFF9B59B6).withOpacity(0.7),
                  ],
                ),
              ),
              child: const Icon(
                Icons.celebration,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You practiced ${_practiceWords.length} words',
              style: GoogleFonts.plusJakartaSans(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Average Score: $averageScore%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF97316), // Orange
              ),
            ),
            const SizedBox(height: 8),
            _buildPerformanceIndicator(averageScore),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Back', style: GoogleFonts.plusJakartaSans()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentWordIndex = 0;
                _totalScore = 0;
                _wordsCompleted = 0;
                _transcribedText = '';
              });
              _loadPracticeWords();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316), // Orange
            ),
            child: Text(
              'Practice Again',
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceIndicator(int score) {
    String message;
    Color color;
    IconData icon;

    if (score >= 90) {
      message = 'Excellent pronunciation skills!';
      color = Colors.green;
      icon = Icons.star;
    } else if (score >= 70) {
      message = 'Great progress! Keep it up!';
      color = Colors.lightGreen;
      icon = Icons.thumb_up;
    } else if (score >= 50) {
      message = 'Good effort! Practice makes perfect!';
      color = Colors.orange;
      icon = Icons.trending_up;
    } else {
      message = 'Keep practicing! You\'ll improve!';
      color = Colors.red;
      icon = Icons.fitness_center;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const practiceColor = Color(0xFFF97316); // Orange - accent color only
    const neutral = Color(0xFFE0E0E0);

    if (_practiceWords.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: Text(
            'Speaking Practice',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: const Color(0xFFF9F9F9),
          foregroundColor: const Color(0xFF333333),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentWord = _practiceWords[_currentWordIndex];

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
                    'Speaking Practice',
                    style: GoogleFonts.plusJakartaSans(
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
                      '${_currentWordIndex + 1}/${_practiceWords.length}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: practiceColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress Bar (quiz style)
                    Column(
                      children: [
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
                                  (_currentWordIndex + 1) /
                                  _practiceWords.length,
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

                    const SizedBox(height: 20),

                    // Instruction
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: practiceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.mic, color: practiceColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Read the word aloud',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'AI will analyze your pronunciation',
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
                    ),

                    const Spacer(),

                    // Word Display
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: practiceColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            currentWord.word,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: practiceColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '/${currentWord.ipa}/',
                            style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentWord.meaning,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Listen to pronunciation button
                          if (currentWord.audioUrl.isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: _isPlayingAudio
                                  ? null
                                  : _playWordAudio,
                              icon: Icon(
                                _isPlayingAudio
                                    ? Icons.volume_up
                                    : Icons.volume_up_outlined,
                                size: 18,
                              ),
                              label: Text(
                                _isPlayingAudio ? 'Playing...' : 'Listen',
                                style: GoogleFonts.plusJakartaSans(),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: practiceColor,
                                side: BorderSide(color: practiceColor),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Transcribed text display
                    if (_transcribedText.isNotEmpty || _isRecording)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isRecording ? Icons.mic : Icons.text_fields,
                              color: _isRecording ? Colors.red : practiceColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isRecording && _transcribedText.isEmpty
                                    ? 'Listening...'
                                    : _transcribedText.isEmpty
                                    ? 'Speak now...'
                                    : _transcribedText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: _transcribedText.isEmpty
                                      ? Colors.grey[500]
                                      : Colors.grey[800],
                                  fontStyle: _transcribedText.isEmpty
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Record Button
                    Center(
                      child: GestureDetector(
                        onTap: _isAnalyzing ? null : _toggleRecording,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isRecording ? 100 : 120,
                          height: _isRecording ? 100 : 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isAnalyzing
                                  ? [Colors.grey, Colors.grey.shade600]
                                  : _isRecording
                                  ? [Colors.red, Colors.red.shade700]
                                  : [
                                      practiceColor,
                                      practiceColor.withOpacity(0.7),
                                    ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_isRecording ? Colors.red : practiceColor)
                                        .withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: _isAnalyzing
                              ? const Padding(
                                  padding: EdgeInsets.all(30),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Icon(
                                  _isRecording ? Icons.stop : Icons.mic,
                                  color: Colors.white,
                                  size: _isRecording ? 48 : 56,
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      _isAnalyzing
                          ? 'Analyzing pronunciation...'
                          : _isRecording
                          ? 'Recording... Tap to stop'
                          : 'Tap to record',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),

                    // Skip Button
                    OutlinedButton(
                      onPressed: _nextWord,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: practiceColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: practiceColor,
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
