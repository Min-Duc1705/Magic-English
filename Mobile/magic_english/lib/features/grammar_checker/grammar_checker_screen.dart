import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/widgets/common/app_bottom_nav.dart';
import 'package:magic_enlish/core/widgets/grammar/grammar_input_card.dart';
import 'package:magic_enlish/core/widgets/grammar/grammar_score_card.dart';
import 'package:magic_enlish/core/widgets/grammar/grammar_summary_card.dart';
import 'package:magic_enlish/core/widgets/grammar/grammar_error_card.dart';
import 'package:magic_enlish/providers/grammar/grammar_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class GrammarCheckerPage extends StatefulWidget {
  const GrammarCheckerPage({super.key});

  @override
  State<GrammarCheckerPage> createState() => _GrammarCheckerPageState();
}

class _GrammarCheckerPageState extends State<GrammarCheckerPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
    // Reset grammar state when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GrammarProvider>(context, listen: false);
      provider.clearCurrentGrammar();
    });
  }

  void _checkGrammar() {
    final provider = Provider.of<GrammarProvider>(context, listen: false);
    provider.checkGrammar(_controller.text);
  }

  Future<void> _pickImageAndExtractText(ImageSource source) async {
    try {
      setState(() {
        _isProcessingImage = true;
      });

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() {
          _isProcessingImage = false;
        });
        return;
      }

      // Process image with ML Kit Text Recognition
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      if (recognizedText.text.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No text found in image',
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
      } else {
        // Fill the text into the input field
        _controller.text = recognizedText.text;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Text extracted successfully!',
                      style: GoogleFonts.lexend(fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xff4CAF50),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      setState(() {
        _isProcessingImage = false;
      });
    } catch (e) {
      setState(() {
        _isProcessingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error extracting text: $e',
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
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Extract Text from Image',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt, color: Color(0xFF4A90E2)),
                ),
                title: Text(
                  'Take Photo',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Use camera to capture text',
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageAndExtractText(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF4A90E2),
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Select an existing photo',
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageAndExtractText(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color background = Color(0xFFF8F9FA);
    const Color borderColor = Color(0xFFEAECEF);

    return Consumer<GrammarProvider>(
      builder: (context, grammarProvider, child) {
        final grammar = grammarProvider.currentGrammar;
        final isLoading = grammarProvider.isLoading;
        final error = grammarProvider.error;

        return GestureDetector(
          onTap: () {
            // Ẩn bàn phím khi tap ra ngoài
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: background,
            body: SafeArea(
              child: Column(
                children: [
                  // Top Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 56,
                    decoration: BoxDecoration(
                      color: background.withOpacity(0.8),
                      border: const Border(
                        bottom: BorderSide(color: borderColor),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 24),
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/home'),
                          padding: EdgeInsets.zero,
                        ),
                        Expanded(
                          child: Text(
                            "Grammar Checker",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lexend(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.image_search,
                            size: 24,
                            color: Color(0xFF4A90E2),
                          ),
                          onPressed: _isProcessingImage
                              ? null
                              : _showImageSourceDialog,
                          tooltip: 'Extract text from image',
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),

                  // Main Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Processing Image Indicator
                          if (_isProcessingImage)
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A90E2).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFF4A90E2,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF4A90E2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Extracting text from image...',
                                      style: GoogleFonts.lexend(
                                        fontSize: 14,
                                        color: const Color(0xFF4A90E2),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Input Section
                          GrammarInputCard(
                            controller: _controller,
                            onCheck: _checkGrammar,
                            isLoading: isLoading,
                          ),

                          // Error Message
                          if (error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE94E77).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFFE94E77,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Color(0xFFE94E77),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      error,
                                      style: GoogleFonts.lexend(
                                        color: const Color(0xFFE94E77),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Results Section
                          if (grammar != null) ...[
                            const SizedBox(height: 24),

                            // Score Card
                            GrammarScoreCard(score: grammar.score),

                            const SizedBox(height: 24),

                            // Summary Card
                            GrammarSummaryCard(grammar: grammar),

                            const SizedBox(height: 24),

                            // Corrected Text Card
                            if (grammar.correctedText.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF4CAF50,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF4CAF50,
                                    ).withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4CAF50),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'Corrected Version',
                                            style: GoogleFonts.lexend(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF4CAF50),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.copy,
                                            color: Color(0xFF4CAF50),
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text: grammar.correctedText,
                                              ),
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        'Copied to clipboard',
                                                        style:
                                                            GoogleFonts.lexend(
                                                              fontSize: 14,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: const Color(
                                                  0xFF4CAF50,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                              ),
                                            );
                                          },
                                          tooltip: 'Copy corrected text',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        grammar.correctedText,
                                        style: GoogleFonts.lexend(
                                          fontSize: 15,
                                          color: const Color(0xFF333333),
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            const SizedBox(height: 16),

                            // Error Details
                            ...grammar.errors.map(
                              (error) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: GrammarErrorCard(error: error),
                              ),
                            ),
                          ],

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const AppBottomNav(currentIndex: 2),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _textRecognizer.close();
    // Clear grammar result when leaving the page
    final provider = Provider.of<GrammarProvider>(context, listen: false);
    provider.clearCurrentGrammar();
    super.dispose();
  }
}
