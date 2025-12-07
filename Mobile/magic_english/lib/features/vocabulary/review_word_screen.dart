import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:magic_enlish/core/widgets/vocabulary/vocabulary_header.dart';
import 'package:magic_enlish/core/widgets/vocabulary/vocabulary_word_section.dart';
import 'package:magic_enlish/core/widgets/vocabulary/vocabulary_info_section.dart';
import 'package:magic_enlish/core/widgets/vocabulary/vocabulary_action_buttons.dart';
import 'package:magic_enlish/data/models/vocabulary/Vocabulary.dart';

class VocabularyDetailScreen extends StatefulWidget {
  final Vocabulary vocabulary;
  final VoidCallback? onNextWord;
  final bool showNextButton;

  const VocabularyDetailScreen({
    super.key,
    required this.vocabulary,
    this.onNextWord,
    this.showNextButton = false,
  });

  @override
  State<VocabularyDetailScreen> createState() => _VocabularyDetailScreenState();
}

class _VocabularyDetailScreenState extends State<VocabularyDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Initialize audio player with LOW_LATENCY mode
    _audioPlayer = AudioPlayer(
      playerId: 'vocabulary_audio_${widget.vocabulary.id}',
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Set audio context for mobile with MAXIMUM compatibility
    _audioPlayer.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.duckOthers,
          },
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.speech,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );

    // Set player mode
    _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        _animationController.stop();
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.release();
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    final audioUrl = widget.vocabulary.audioUrl;

    // Check if audio URL is available
    if (audioUrl.isEmpty || audioUrl == 'null' || audioUrl == 'N/A') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Audio not available for this word',
              style: GoogleFonts.lexend(),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      if (_isPlaying) {
        // Stop current audio
        await _audioPlayer.stop();
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
          _animationController.stop();
          _animationController.reset();
        }
      } else {
        // Start playing audio
        if (mounted) {
          setState(() {
            _isPlaying = true;
          });
          _animationController.repeat();
        }

        // Reset player
        await _audioPlayer.stop();
        await _audioPlayer.release();

        // Configure player
        await _audioPlayer.setReleaseMode(ReleaseMode.stop);
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.setPlaybackRate(1.0);

        // Force audio routing to speaker
        await _audioPlayer.setAudioContext(
          AudioContext(
            android: AudioContextAndroid(
              isSpeakerphoneOn: true,
              stayAwake: true,
              contentType: AndroidContentType.music,
              usageType: AndroidUsageType.media,
              audioFocus: AndroidAudioFocus.gain,
            ),
          ),
        );

        // Play audio
        await _audioPlayer.play(
          UrlSource(audioUrl),
          volume: 1.0,
          mode: PlayerMode.mediaPlayer,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot play audio: ${e.toString()}',
              style: GoogleFonts.lexend(fontSize: 12),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {
          _isPlaying = false;
        });
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  Color get primary => const Color(0xFF4A90E2);
  Color get background => const Color(0xfff6f6f8);
  Color get cardBg => Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            const VocabularyHeader(),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Word and Audio Section
                            VocabularyWordSection(
                              word: widget.vocabulary.word,
                              ipa: widget.vocabulary.ipa,
                              isPlaying: _isPlaying,
                              onAudioTap: _playAudio,
                              animation: _animationController,
                              primaryColor: primary,
                            ),

                            const SizedBox(height: 16),
                            Container(height: 1.2, color: Colors.grey.shade300),
                            const SizedBox(height: 18),

                            // Vocabulary Information Section
                            VocabularyInfoSection(
                              meaning: widget.vocabulary.meaning,
                              wordType: widget.vocabulary.wordType,
                              cefrLevel: widget.vocabulary.cefrLevel,
                              examples: widget.vocabulary.example,
                              primaryColor: primary,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Buttons
            VocabularyActionButtons(
              onKnowWord: () => Navigator.pop(context),
              onReviewAgain: widget.onNextWord ?? () => Navigator.pop(context),
              primaryColor: primary,
              knowText: 'I know this word',
              reviewText: widget.showNextButton ? 'Next word' : 'Review again',
            ),
          ],
        ),
      ),
    );
  }
}
