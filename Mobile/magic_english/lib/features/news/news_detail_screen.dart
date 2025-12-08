import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/data/models/news/news_article.dart';
import 'package:magic_enlish/core/widgets/common/app_top_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:magic_enlish/data/models/vocabulary/Vocabulary.dart';
import 'package:magic_enlish/data/repositories/vocabulary/vocabulary_repository.dart';
import 'package:provider/provider.dart';
import 'package:magic_enlish/providers/vocabulary/vocabulary_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsArticle article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  String? fullContent;
  bool isLoading = true;
  String? errorMessage;
  String? selectedWord;
  TextSelection? currentSelection;
  final VocabularyRepository _vocabularyRepository = VocabularyRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadFullContent();
  }

  Future<void> _loadFullContent() async {
    // First check if we already have full content from RSS
    if (widget.article.fullContent != null &&
        widget.article.fullContent!.isNotEmpty) {
      setState(() {
        fullContent = widget.article.fullContent;
        isLoading = false;
      });
      return;
    }

    // Fallback: try to fetch from web if RSS didn't include full content
    try {
      final response = await http.get(Uri.parse(widget.article.link));
      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        // VNExpress article content selector
        final contentElements = document.querySelectorAll(
          '.Normal, .fck_detail p',
        );
        final content = contentElements
            .map((e) => e.text.trim())
            .where((text) => text.isNotEmpty)
            .join('\n\n');

        setState(() {
          fullContent = content.isNotEmpty
              ? content
              : widget.article.description;
          isLoading = false;
        });
      } else {
        setState(() {
          fullContent = widget.article.description;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        fullContent = widget.article.description;
        isLoading = false;
      });
    }
  }

  void _showWordContextMenu(
    BuildContext context,
    String selectedText,
    TextSelection selection,
  ) {
    setState(() {
      selectedWord = selectedText;
    });

    // Get the render box of the SelectableText widget
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Calculate approximate position of selected text
    // This is a simplified approach - text position within the widget
    final boxSize = renderBox.size;
    final localPosition = Offset(
      boxSize.width * 0.5, // Center horizontally
      selection.start *
          0.5, // Approximate vertical position based on character index
    );
    final globalPosition = renderBox.localToGlobal(localPosition);

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromLTWH(
        globalPosition.dx - 80, // Center menu horizontally
        globalPosition.dy + 40, // Show below the selected word
        160,
        50,
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'add_vocab',
          child: Row(
            children: [
              const Icon(Icons.add_circle_outline, color: Color(0xFF4A90E2)),
              const SizedBox(width: 12),
              Text(
                'Add to Vocabulary',
                style: GoogleFonts.lexend(fontSize: 14),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'lookup',
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF4A90E2)),
              const SizedBox(width: 12),
              Text('Look Up Meaning', style: GoogleFonts.lexend(fontSize: 14)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'pronounce',
          child: Row(
            children: [
              const Icon(Icons.volume_up, color: Color(0xFF4A90E2)),
              const SizedBox(width: 12),
              Text('Pronounce', style: GoogleFonts.lexend(fontSize: 14)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              const Icon(Icons.copy, color: Color(0xFF4A90E2)),
              const SizedBox(width: 12),
              Text('Copy', style: GoogleFonts.lexend(fontSize: 14)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleMenuAction(value, selectedText);
      }
      // Clear selection highlight after menu closes
      setState(() {
        selectedWord = null;
      });
    });
  }

  void _handleMenuAction(String action, String word) {
    switch (action) {
      case 'add_vocab':
        _addToVocabulary(word);
        break;
      case 'lookup':
        _lookupMeaning(word);
        break;
      case 'pronounce':
        _pronounceWord(word);
        break;
      case 'copy':
        _copyWord(word);
        break;
    }
  }

  Future<void> _addToVocabulary(String word) async {
    // Show preview dialog with word meaning
    await showDialog(
      context: context,
      builder: (BuildContext context) => _VocabularyPreviewDialog(
        word: word,
        vocabularyRepository: _vocabularyRepository,
        onPronounce: _pronounceWord,
      ),
    );
  }

  void _lookupMeaning(String word) {
    // TODO: Integrate with dictionary API
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Looking up "$word"...')));
  }

  Future<void> _pronounceWord(String word, [String? audioUrl]) async {
    if (audioUrl != null && audioUrl.isNotEmpty) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Error playing audio',
                      style: GoogleFonts.lexend(fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.volume_off, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Audio not available',
                    style: GoogleFonts.lexend(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _copyWord(String word) {
    Clipboard.setData(ClipboardData(text: word));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied "$word" to clipboard')));
  }

  Future<void> _openOriginalArticle() async {
    final uri = Uri.parse(widget.article.link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  List<TextSpan> _buildHighlightedText(String text) {
    if (selectedWord == null) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    final words = text.split(' ');

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');

      if (cleanWord.toLowerCase() == selectedWord!.toLowerCase()) {
        // Highlight selected word
        spans.add(
          TextSpan(
            text: word,
            style: GoogleFonts.lexend(
              backgroundColor: const Color(0xFF4A90E2).withOpacity(0.3),
              color: const Color(0xFF4A90E2),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: word));
      }

      if (i < words.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return spans;
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final offset = date.timeZoneOffset.inHours;
    final offsetStr = offset >= 0 ? '+$offset' : '$offset';

    return '${months[date.month - 1]} ${date.day}, ${date.year} | $hour:$minute pm GMT$offsetStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f6f8),
      body: SafeArea(
        child: Column(
          children: [
            AppTopBar(
              title: "Article",
              rightAction: IconButton(
                icon: const Icon(Icons.open_in_browser),
                onPressed: _openOriginalArticle,
                tooltip: 'Open in browser',
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image
                    if (widget.article.imageUrl != null)
                      Container(
                        width: double.infinity,
                        height: 240,
                        decoration: BoxDecoration(color: Colors.grey.shade300),
                        child: Image.network(
                          widget.article.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.image,
                                size: 80,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            widget.article.title,
                            style: GoogleFonts.lexend(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Author
                          Row(
                            children: [
                              Text(
                                'By ',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                widget.article.author ?? 'VNExpress',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Date and Time
                          if (widget.article.pubDate != null)
                            Row(
                              children: [
                                Text(
                                  _formatDate(widget.article.pubDate!),
                                  style: GoogleFonts.lexend(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),

                          // Time ago and Category
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.article.getTimeAgo(),
                                style: GoogleFonts.lexend(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 16),
                              if (widget.article.category != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF4A90E2,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.article.category!,
                                    style: GoogleFonts.lexend(
                                      fontSize: 12,
                                      color: const Color(0xFF4A90E2),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 24),

                          // Content
                          if (isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(
                                  color: Color(0xFF4A90E2),
                                ),
                              ),
                            )
                          else
                            SelectableText.rich(
                              TextSpan(
                                children: _buildHighlightedText(
                                  fullContent ?? widget.article.description,
                                ),
                              ),
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                color: Colors.black87,
                                height: 1.8,
                                letterSpacing: 0.2,
                              ),
                              onSelectionChanged: (selection, cause) {
                                if (selection.start != selection.end) {
                                  final selectedText =
                                      (fullContent ??
                                              widget.article.description)
                                          .substring(
                                            selection.start,
                                            selection.end,
                                          )
                                          .trim();

                                  if (selectedText.isNotEmpty &&
                                      selectedText.split(' ').length == 1) {
                                    // Only show menu if single word is selected
                                    currentSelection = selection;
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (context.mounted) {
                                            _showWordContextMenu(
                                              context,
                                              selectedText,
                                              selection,
                                            );
                                          }
                                        });
                                  }
                                }
                              },
                            ),

                          const SizedBox(height: 60),
                        ],
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

// Vocabulary Preview Dialog Widget
class _VocabularyPreviewDialog extends StatefulWidget {
  final String word;
  final VocabularyRepository vocabularyRepository;
  final Function(String, [String?]) onPronounce;

  const _VocabularyPreviewDialog({
    required this.word,
    required this.vocabularyRepository,
    required this.onPronounce,
  });

  @override
  State<_VocabularyPreviewDialog> createState() =>
      _VocabularyPreviewDialogState();
}

class _VocabularyPreviewDialogState extends State<_VocabularyPreviewDialog> {
  bool _isLoadingPreview = true;
  bool _isSaving = false;
  Vocabulary? _previewVocabulary;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    int retryCount = 0;
    const maxRetries = 2;

    while (retryCount <= maxRetries) {
      try {
        final vocabulary = Vocabulary(
          word: widget.word.toLowerCase(),
          ipa: '',
          audioUrl: '',
          meaning: '',
          wordType: '',
          example: '',
          cefrLevel: '',
          createdAt: DateTime.now(),
        );

        final previewVocab = await widget.vocabularyRepository
            .previewVocabulary(vocabulary);

        if (mounted) {
          // Debug: Print audioUrl to check if it's received from API
          print('Preview response - word: ${previewVocab.word}');
          print('Preview response - audioUrl: ${previewVocab.audioUrl}');
          print(
            'Preview response - audioUrl isEmpty: ${previewVocab.audioUrl.isEmpty}',
          );

          setState(() {
            _previewVocabulary = previewVocab;
            _isLoadingPreview = false;
          });
          return; // Success, exit retry loop
        } else {
          throw Exception('Failed to load word meaning');
        }
      } catch (e) {
        retryCount++;
        print('Preview attempt $retryCount failed: $e');

        if (retryCount > maxRetries) {
          // Max retries reached, show error
          if (mounted) {
            setState(() {
              _errorMessage = e.toString().contains('timeout')
                  ? 'Server đang bận, vui lòng thử lại sau'
                  : 'Error loading word: $e';
              _isLoadingPreview = false;
            });
          }
        } else {
          // Wait before retry
          await Future.delayed(Duration(seconds: retryCount));
        }
      }
    }
  }

  Future<void> _saveToVocabulary() async {
    if (_previewVocabulary == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = Provider.of<VocabularyProvider>(context, listen: false);

      // Close this dialog first, then show achievement dialog on parent context
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Get the parent context from the navigator
      final navigatorContext = Navigator.of(
        context,
        rootNavigator: true,
      ).context;

      // Now call addVocabulary with parent context so achievement dialog shows correctly
      await provider.addVocabulary(_previewVocabulary!, navigatorContext);

      if (provider.error != null) {
        throw Exception(provider.error);
      }

      // Show success snackbar using parent context
      ScaffoldMessenger.of(navigatorContext).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Added "${widget.word}" to vocabulary',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xff4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.menu_book, color: Color(0xFF4A90E2), size: 28),
                const SizedBox(width: 12),
                Text(
                  'Add to Vocabulary',
                  style: GoogleFonts.lexend(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content
            if (_isLoadingPreview)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
                ),
              )
            else if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              )
            else if (_previewVocabulary != null) ...[
              // Word Preview Card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4A90E2).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Word with Pronunciation Button
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _previewVocabulary!.word,
                            style: GoogleFonts.lexend(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4A90E2),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.volume_up,
                            color: _previewVocabulary!.audioUrl.isEmpty
                                ? Colors.grey
                                : const Color(0xFF4A90E2),
                          ),
                          tooltip: _previewVocabulary!.audioUrl.isEmpty
                              ? 'Audio not available'
                              : 'Play pronunciation',
                          onPressed: () => widget.onPronounce(
                            _previewVocabulary!.word,
                            _previewVocabulary!.audioUrl,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // IPA
                    if (_previewVocabulary!.ipa.isNotEmpty) ...[
                      Text(
                        _previewVocabulary!.ipa,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'serif',
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Meaning
                    if (_previewVocabulary!.meaning.isNotEmpty) ...[
                      Text(
                        'Meaning:',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _previewVocabulary!.meaning,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Example
                    if (_previewVocabulary!.example.isNotEmpty) ...[
                      Text(
                        'Example:',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _previewVocabulary!.example,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.lexend(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: (_isSaving || _previewVocabulary == null)
                      ? null
                      : _saveToVocabulary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Save',
                          style: GoogleFonts.lexend(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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
}
