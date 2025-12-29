import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:magic_enlish/core/widgets/vocabulary/cefr_level_badge.dart';
import 'package:magic_enlish/core/widgets/vocabulary/example_item_widget.dart';
import 'package:magic_enlish/data/models/vocabulary/Vocabulary.dart';
import 'package:magic_enlish/core/utils/backend_utils.dart';

class VocabularyPreviewCard extends StatefulWidget {
  final Vocabulary? vocabulary;
  final bool isLoading;
  final Color primaryColor;

  const VocabularyPreviewCard({
    super.key,
    this.vocabulary,
    this.isLoading = false,
    this.primaryColor = const Color(0xFF3A57E8),
  });

  @override
  State<VocabularyPreviewCard> createState() => _VocabularyPreviewCardState();
}

class _VocabularyPreviewCardState extends State<VocabularyPreviewCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (widget.vocabulary?.audioUrl == null ||
        widget.vocabulary!.audioUrl.isEmpty) {
      // Try TTS if no audio URL
      if (widget.vocabulary != null) {
        final ttsUrl = BackendUtils.getFullUrl(
          '/tts?text=${Uri.encodeComponent(widget.vocabulary!.word)}',
        );
        try {
          setState(() => _isPlaying = true);
          await _audioPlayer.play(UrlSource(ttsUrl));
          _audioPlayer.onPlayerComplete.listen((_) {
            if (mounted) setState(() => _isPlaying = false);
          });
        } catch (e) {
          if (mounted) setState(() => _isPlaying = false);
        }
      }
      return;
    }

    try {
      setState(() => _isPlaying = true);
      String audioUrl = widget.vocabulary!.audioUrl;
      if (!audioUrl.startsWith('http')) {
        audioUrl = BackendUtils.getFullUrl('/storage/audio/$audioUrl');
      }
      await _audioPlayer.play(UrlSource(audioUrl));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    } catch (e) {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    if (widget.vocabulary == null) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Word and IPA
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vocabulary!.word,
                      style: GoogleFonts.lexend(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (widget.vocabulary!.ipa.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.vocabulary!.ipa,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontFamily: 'serif',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: _isPlaying ? _stopAudio : _playAudio,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.volume_up,
                      color: widget.primaryColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Container(height: 1.2, color: Colors.grey.shade300),
          const SizedBox(height: 16),

          // Meaning
          if (widget.vocabulary!.meaning.isNotEmpty) ...[
            Text(
              "Meaning",
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.vocabulary!.meaning,
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Word Type and CEFR Level
          Row(
            children: [
              if (widget.vocabulary!.wordType.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Type",
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.vocabulary!.wordType,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.vocabulary!.cefrLevel.isNotEmpty)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Level",
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      CefrLevelBadge(
                        level: widget.vocabulary!.cefrLevel,
                        animated: false,
                        fontSize: 12,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Examples
          if (widget.vocabulary!.example.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              "Example",
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            ...widget.vocabulary!.example
                .split('\n')
                .where((e) => e.trim().isNotEmpty)
                .take(2)
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: ExampleItem(text: e, iconColor: widget.primaryColor),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          CircularProgressIndicator(color: widget.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Looking up word...',
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.search, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Preview will appear here',
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
