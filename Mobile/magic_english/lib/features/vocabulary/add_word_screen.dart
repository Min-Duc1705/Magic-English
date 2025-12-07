import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:magic_enlish/core/widgets/common/app_bottom_nav.dart';
import 'package:magic_enlish/core/widgets/common/app_top_bar.dart';
import 'package:magic_enlish/core/widgets/form/word_input_field.dart';
import 'package:magic_enlish/core/widgets/vocabulary/vocabulary_preview_card.dart';
import 'package:magic_enlish/core/widgets/common/success_dialog.dart';
import 'package:magic_enlish/data/models/vocabulary/Vocabulary.dart';
import 'package:magic_enlish/data/repositories/vocabulary/vocabulary_repository.dart';
import 'package:magic_enlish/features/vocabulary/review_word_screen.dart';
import 'package:magic_enlish/providers/vocabulary/vocabulary_provider.dart';

class AddWordPage extends StatefulWidget {
  const AddWordPage({super.key});

  @override
  State<AddWordPage> createState() => _AddWordPageState();
}

class _AddWordPageState extends State<AddWordPage> {
  final TextEditingController _wordController = TextEditingController();
  final VocabularyRepository _vocabularyRepository = VocabularyRepository();
  bool _isLoading = false;
  bool _isPreviewLoading = false;
  Vocabulary? _previewVocabulary;
  Timer? _debounceTimer;
  String _lastFetchedWord = '';
  String? _wordError;

  @override
  void dispose() {
    _wordController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onWordChanged(String word) {
    _debounceTimer?.cancel();

    if (word.trim().isEmpty) {
      setState(() {
        _previewVocabulary = null;
        _isPreviewLoading = false;
      });
      return;
    }

    setState(() {
      _isPreviewLoading = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 2000), () {
      final trimmedWord = word.trim().toLowerCase();
      // Skip if already fetched this word
      if (trimmedWord == _lastFetchedWord) {
        setState(() {
          _isPreviewLoading = false;
        });
        return;
      }
      _fetchPreview(trimmedWord);
    });
  }

  Future<void> _fetchPreview(String word) async {
    try {
      final vocabulary = Vocabulary(
        word: word,
        ipa: '',
        audioUrl: '',
        meaning: '',
        wordType: '',
        example: '',
        cefrLevel: '',
        createdAt: DateTime.now(),
      );

      // Use preview API (doesn't save to DB) with 10 second timeout
      final previewVocab = await _vocabularyRepository
          .previewVocabulary(vocabulary)
          .timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _previewVocabulary = previewVocab;
          _lastFetchedWord = word.toLowerCase();
          _isPreviewLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _previewVocabulary = null;
          _isPreviewLoading = false;
        });

        // Show timeout/error message
        if (e.toString().contains('TimeoutException')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Server response too slow. Please try again.',
                style: GoogleFonts.lexend(),
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  // Colors
  Color get primary => const Color(0xFF3A57E8);
  Color get secondary => const Color(0xFF00C49A);
  Color get backgroundLight => const Color(0xFFF8F9FA);
  Color get textLight => const Color(0xFF333333);
  Color get placeholder => const Color(0xFFADB5BD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,

      // Bottom Navigation
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),

      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            const AppTopBar(title: 'Add New Word'),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Input Field
                    WordInputField(
                      controller: _wordController,
                      enabled: !_isLoading,
                      labelText: 'Enter an English word',
                      hintText: 'e.g., serendipity',
                      helperText:
                          'Our AI will automatically find the meaning, pronunciation, and examples for you.',
                      errorText: _wordError,
                      onChanged: (value) {
                        // Clear error when user starts typing
                        if (_wordError != null) {
                          setState(() => _wordError = null);
                        }
                        _onWordChanged(value);
                      },
                      onMicTap: () {
                        // TODO: Implement voice input
                      },
                      primaryColor: primary,
                      secondaryColor: secondary,
                    ),

                    const SizedBox(height: 20),

                    // Preview Card
                    VocabularyPreviewCard(
                      vocabulary: _previewVocabulary,
                      isLoading: _isPreviewLoading,
                      primaryColor: primary,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ---------------- ADD BUTTON ----------------
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isLoading ? null : _handleAddWord,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        "Add Word",
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddWord() async {
    final word = _wordController.text.trim();

    // Validate input
    if (word.isEmpty) {
      setState(() => _wordError = 'Please enter a word');
      return;
    }

    // Check if word contains only letters and spaces
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(word)) {
      setState(() => _wordError = 'Word should contain only letters');
      return;
    }

    // Check minimum length
    if (word.length < 2) {
      setState(() => _wordError = 'Word must be at least 2 characters');
      return;
    }

    // Clear any previous error
    setState(() => _wordError = null);

    setState(() {
      _isLoading = true;
    });

    try {
      // Create vocabulary object with only the word (AI will enrich it)
      final vocabulary = Vocabulary(
        word: word,
        ipa: '',
        audioUrl: '',
        meaning: '',
        wordType: '',
        example: '',
        cefrLevel: '',
        createdAt: DateTime.now(),
      );

      // Add vocabulary through provider
      final provider = Provider.of<VocabularyProvider>(context, listen: false);
      await provider.addVocabulary(vocabulary, context);

      if (provider.error != null) {
        throw Exception(provider.error);
      }

      // Get the newly added vocabulary
      final addedVocab = provider.vocabularies.firstWhere(
        (v) => v.word.toLowerCase() == word.toLowerCase(),
        orElse: () => vocabulary,
      );

      // Show success dialog
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        await SuccessDialog.show(
          context: context,
          title: 'Word Added!',
          message: '"${addedVocab.word}" is now in your vocabulary list.',
          onViewWord: () {
            Navigator.pop(context); // Close dialog
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VocabularyDetailScreen(vocabulary: addedVocab),
              ),
            ).then((_) {
              if (mounted) {
                Navigator.pop(context, true); // Close add word screen
              }
            });
          },
          onContinue: () {
            Navigator.pop(context); // Close dialog
            // Clear input and preview for next word
            _wordController.clear();
            setState(() {
              _previewVocabulary = null;
              _lastFetchedWord = '';
            });
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.lexend()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
