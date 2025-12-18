import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:magic_enlish/providers/vocabulary/vocabulary_provider.dart';
import 'package:magic_enlish/data/models/vocabulary/Vocabulary.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class ListeningPracticeScreen extends StatefulWidget {
  const ListeningPracticeScreen({super.key});

  @override
  State<ListeningPracticeScreen> createState() =>
      _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState extends State<ListeningPracticeScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isChecked = false;
  bool _isPlaying = false;
  String? _validationError;
  List<Vocabulary> _exercises = [];
  final TextEditingController _answerController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Speech to text
  late stt.SpeechToText _speech;
  bool _isListening = false;

  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadExercises();
  }

  Future<void> _startListening() async {
    // Request permission if not granted
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission required')),
          );
        }
        return;
      }
    }

    // Emulator robustness: Reset speech instance
    try {
      if (_isListening) {
        await _speech.stop();
        await _speech.cancel();
      }
    } catch (e) {
      print('Error stopping speech: $e');
    }

    _speech = stt.SpeechToText(); // Re-create instance

    try {
      bool available = await _speech.initialize(
        onError: (val) {
          print('Speech error: $val');
          if (mounted) {
            setState(() => _isListening = false);
            String message = 'Error: ${val.errorMsg}';
            if (val.errorMsg == 'error_speech_timeout') {
              message = 'No speech detected. Please speak louder.';
            } else if (val.errorMsg == 'error_no_match') {
              message = 'Could not understand. Try checking your microphone.';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.orange),
            );
          }
        },
        onStatus: (val) {
          print('Speech status: $val');
          if (val == 'done') {
            if (mounted) {
              setState(() => _isListening = false);
              // Auto-check answer when done
              if (_answerController.text.isNotEmpty && !_isChecked) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    _checkAnswer();
                  }
                });
              }
            }
          } else if (val == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );

      if (available) {
        // Clear previous input
        setState(() {
          _lastWords = '';
          _answerController.clear();
        });

        // Find best English locale
        var locales = await _speech.locales();
        var selectedLocaleId = 'en_US'; // Default

        // Try to find specific English locales in order of preference
        var preferredLocales = ['en_US', 'en_GB', 'en_AU', 'en_IN', 'en'];
        bool found = false;

        for (var pref in preferredLocales) {
          try {
            var match = locales.firstWhere((l) => l.localeId.startsWith(pref));
            selectedLocaleId = match.localeId;
            found = true;
            print('Selected locale: $selectedLocaleId');
            break;
          } catch (e) {
            continue;
          }
        }

        // If exact match not found but we have locales, try any 'en'
        if (!found && locales.isNotEmpty) {
          try {
            var match = locales.firstWhere(
              (l) => l.localeId.toLowerCase().startsWith('en'),
              orElse: () => locales.first,
            );
            selectedLocaleId = match.localeId;
            print('Fallback locale: $selectedLocaleId');
          } catch (e) {
            print('Locale selection error: $e');
          }
        }

        setState(() => _isListening = true);

        await _speech.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
              _answerController.text = _lastWords;
            });
          },
          localeId: selectedLocaleId,
          onDevice: false, // Prefer server-side for "Google-like" smarts
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: false, // Wait for stable results
          cancelOnError: true,
          listenMode: stt.ListenMode.search, // Better for short phrases
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition initialized but not available'),
            ),
          );
        }
      }
    } catch (e) {
      print('Speech init exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not initialize speech recognition. Try again.',
            ),
          ),
        );
      }
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _answerController.dispose();
    _audioPlayer.stop();
    _audioPlayer.release();
    _audioPlayer.dispose();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    final provider = Provider.of<VocabularyProvider>(context, listen: false);
    await provider.loadVocabularies();

    if (provider.vocabularies.isEmpty) return;

    setState(() {
      _exercises =
          (provider.vocabularies.where((v) => v.audioUrl.isNotEmpty).toList()
                ..shuffle())
              .take(10)
              .toList();
    });
  }

  Future<void> _playAudio() async {
    if (_exercises.isEmpty) return;

    final currentVocab = _exercises[_currentQuestionIndex];
    if (currentVocab.audioUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No audio available', style: GoogleFonts.lexend()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isPlaying = true);

    try {
      await _audioPlayer.play(UrlSource(currentVocab.audioUrl));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() => _isPlaying = false);
        }
      });
    } catch (e) {
      print('Error playing audio: $e');
      if (mounted) {
        setState(() => _isPlaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio', style: GoogleFonts.lexend()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _checkAnswer() {
    if (_answerController.text.trim().isEmpty) {
      setState(() {
        _validationError = 'Please enter what you heard';
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
        _lastWords = '';
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
          'Listening Practice Complete! 🎧',
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
                color: const Color(0xFF9B59B6), // Purple
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
                _lastWords = '';
              });
              _loadExercises();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B59B6), // Purple
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
    const practiceColor = Color(0xFF9B59B6); // Purple - accent color only
    const neutral = Color(0xFFE0E0E0);

    if (_exercises.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: Text('Listening Practice', style: GoogleFonts.lexend()),
          backgroundColor: const Color(0xFFF9F9F9),
          foregroundColor: const Color(0xFF333333),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentVocab = _exercises[_currentQuestionIndex];
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
                    'Listening Practice',
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
                    // Progress Bar
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
                          Icon(Icons.headphones, color: practiceColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Listen carefully and type what you hear',
                              style: GoogleFonts.lexend(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Audio Player
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _isChecked ? null : _playAudio,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    practiceColor,
                                    practiceColor.withOpacity(0.7),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: practiceColor.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isPlaying ? Icons.volume_up : Icons.play_arrow,
                                color: Colors.white,
                                size: 56,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isPlaying ? 'Playing...' : 'Tap to play audio',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

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
                        labelText: 'What did you hear?',
                        hintText: 'Type the word here',
                        prefixIcon: Icon(
                          Icons.edit,
                          color: _validationError != null
                              ? Colors.red
                              : practiceColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.red : Colors.grey,
                          ),
                          onPressed: _isChecked
                              ? null
                              : () {
                                  if (_isListening) {
                                    _stopListening();
                                  } else {
                                    _startListening();
                                  }
                                },
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
                                    isCorrect ? 'Perfect! 🎉' : 'Not quite',
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              '/${currentVocab.ipa}/',
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                              : 'Finish Practice',
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
