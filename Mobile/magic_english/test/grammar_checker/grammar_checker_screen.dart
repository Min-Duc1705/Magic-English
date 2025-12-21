import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GrammarCheckerPage extends StatefulWidget {
  const GrammarCheckerPage({super.key});

  @override
  State<GrammarCheckerPage> createState() => _GrammarCheckerPageState();
}

class _GrammarCheckerPageState extends State<GrammarCheckerPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isChecked = false;

  // Static grammar check result
  final Map<String, dynamic> _grammarResult = {
    'score': 78,
    'totalErrors': 3,
    'totalWords': 45,
    'originalText':
        'I goes to the store yesterday and buy some apples. The weather was very nice.',
    'correctedText':
        'I went to the store yesterday and bought some apples. The weather was very nice.',
    'errors': [
      {
        'type': 'Grammar',
        'message': 'Incorrect verb form',
        'original': 'goes',
        'suggestion': 'went',
        'explanation': 'Use past tense for actions that happened yesterday',
        'severity': 'high',
      },
      {
        'type': 'Grammar',
        'message': 'Incorrect verb form',
        'original': 'buy',
        'suggestion': 'bought',
        'explanation': 'Use past tense to match the sentence context',
        'severity': 'high',
      },
      {
        'type': 'Style',
        'message': 'Consider using more descriptive word',
        'original': 'very nice',
        'suggestion': 'beautiful',
        'explanation': 'Using more specific adjectives improves clarity',
        'severity': 'low',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _controller.text = _grammarResult['originalText'];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkGrammar() {
    setState(() {
      _isChecked = true;
    });
  }

  void _clearText() {
    setState(() {
      _controller.clear();
      _isChecked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 28),
                  ),
                  const Spacer(),
                  Text(
                    'Grammar Checker',
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('About Grammar Checker'),
                          content: const Text(
                            'This tool helps you check and correct grammar mistakes in your text.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
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
                    // Input Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Enter Your Text',
                                style: GoogleFonts.lexend(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.camera_alt, size: 20),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Camera feature'),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.image, size: 20),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Gallery feature'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _controller,
                            maxLines: 8,
                            decoration: InputDecoration(
                              hintText: 'Type or paste your text here...',
                              hintStyle: GoogleFonts.lexend(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_controller.text.split(' ').where((w) => w.isNotEmpty).length} words',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: _clearText,
                                    icon: const Icon(Icons.clear, size: 16),
                                    label: const Text('Clear'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: _controller.text.isEmpty
                                        ? null
                                        : _checkGrammar,
                                    icon: const Icon(Icons.check_circle, size: 18),
                                    label: const Text('Check Grammar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Results Section (only show when checked)
                    if (_isChecked) ...[
                      const SizedBox(height: 24),

                      // Score Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primary, primary.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Grammar Score',
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${_grammarResult['score']}',
                              style: GoogleFonts.lexend(
                                fontSize: 48,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_grammarResult['totalErrors']} errors found',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Summary Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Corrected Text',
                              style: GoogleFonts.lexend(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _grammarResult['correctedText'],
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Errors List
                      Text(
                        'Detected Errors (${_grammarResult['totalErrors']})',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      ...(_grammarResult['errors'] as List).map((error) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildErrorCard(error),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Vocabulary'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Practice'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildErrorCard(Map<String, dynamic> error) {
    Color severityColor;
    IconData severityIcon;

    switch (error['severity']) {
      case 'high':
        severityColor = Colors.red;
        severityIcon = Icons.error;
        break;
      case 'medium':
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      default:
        severityColor = Colors.blue;
        severityIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: severityColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(severityIcon, color: severityColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      error['type'],
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: severityColor,
                      ),
                    ),
                    Text(
                      error['message'],
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    error['original'],
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      color: Colors.red[700],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 16),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    error['suggestion'],
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error['explanation'],
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
