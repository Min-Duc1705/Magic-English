import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:magic_enlish/data/models/vocabulary/Vocabulary.dart';
import 'package:magic_enlish/core/utils/backend_utils.dart';

class RecentWordsSection extends StatefulWidget {
  final List<Vocabulary> recentWords;
  final bool isLoading;
  final String? error;

  const RecentWordsSection({
    super.key,
    required this.recentWords,
    this.isLoading = false,
    this.error,
  });

  @override
  State<RecentWordsSection> createState() => _RecentWordsSectionState();
}

class _RecentWordsSectionState extends State<RecentWordsSection> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingWordId; // Track which word is currently playing

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(Vocabulary vocab) async {
    // If already playing this word, stop it
    if (_playingWordId == vocab.word) {
      await _audioPlayer.stop();
      setState(() => _playingWordId = null);
      return;
    }

    // Stop any currently playing audio
    await _audioPlayer.stop();

    try {
      setState(() => _playingWordId = vocab.word);

      String audioUrl;
      if (vocab.audioUrl.isNotEmpty) {
        // Use saved audio URL
        if (vocab.audioUrl.startsWith('http')) {
          audioUrl = vocab.audioUrl;
        } else {
          audioUrl = BackendUtils.getFullUrl(
            '/storage/audio/${vocab.audioUrl}',
          );
        }
      } else {
        // Use TTS
        audioUrl = BackendUtils.getFullUrl(
          '/tts?text=${Uri.encodeComponent(vocab.word)}',
        );
      }

      await _audioPlayer.play(UrlSource(audioUrl));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _playingWordId = null);
      });
    } catch (e) {
      if (mounted) setState(() => _playingWordId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recently Added Words",
          style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        if (widget.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (widget.error != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                widget.error!,
                style: GoogleFonts.lexend(color: Colors.red, fontSize: 14),
              ),
            ),
          )
        else if (widget.recentWords.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "No words added yet",
                style: GoogleFonts.lexend(color: Colors.grey, fontSize: 14),
              ),
            ),
          )
        else
          ...widget.recentWords.map((vocab) {
            final isPlaying = _playingWordId == vocab.word;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vocab.word,
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vocab.meaning,
                            style: GoogleFonts.lexend(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _playAudio(vocab),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A57E8).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.volume_up,
                            size: 18,
                            color: const Color(0xFF3A57E8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
