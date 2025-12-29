import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/data/models/grammar/grammar.dart';
import 'package:magic_enlish/data/services/grammar_service.dart';
import 'package:intl/intl.dart';

class GrammarHistoryScreen extends StatefulWidget {
  const GrammarHistoryScreen({super.key});

  @override
  State<GrammarHistoryScreen> createState() => _GrammarHistoryScreenState();
}

class _GrammarHistoryScreenState extends State<GrammarHistoryScreen> {
  final GrammarService _grammarService = GrammarService();
  List<Grammar> _grammarHistory = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;
  int _totalPages = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory({int page = 0}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _grammarService.getAllGrammarChecks(
        page: page,
        size: _pageSize,
      );

      setState(() {
        _grammarHistory = result['grammars'] as List<Grammar>;
        final meta = result['meta'];
        if (meta != null) {
          _currentPage = meta['page'] ?? 0;
          _totalPages = meta['pages'] ?? 1;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteGrammarCheck(int id) async {
    try {
      await _grammarService.deleteGrammarCheck(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                'Deleted successfully',
                style: GoogleFonts.lexend(fontSize: 14),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
      _loadHistory(page: _currentPage);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Failed to delete: $e',
                  style: GoogleFonts.lexend(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showDeleteConfirmDialog(Grammar grammar) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Grammar Check',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this grammar check?',
            style: GoogleFonts.lexend(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.lexend(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteGrammarCheck(grammar.id);
              },
              child: Text(
                'Delete',
                style: GoogleFonts.lexend(color: Colors.red),
              ),
            ),
          ],
          backgroundColor: Theme.of(context).cardColor,
          titleTextStyle: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
          contentTextStyle: GoogleFonts.lexend(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFFFFA726);
    return const Color(0xFFE94E77);
  }

  Color _getErrorTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'spelling':
        return const Color(0xFFE94E77); // Pink
      case 'punctuation':
        return const Color(0xFF4A90E2); // Blue
      case 'clarity':
        return const Color(0xFFF5A623); // Orange
      case 'grammar':
      default:
        return const Color(0xFF9B59B6); // Purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF8F9FA);
    final borderColor = isDark
        ? const Color(0xFF3D3D3D)
        : const Color(0xFFEAECEF);
    final textPrimary = isDark ? Colors.white : const Color(0xFF333333);
    final appBarBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 56,
              decoration: BoxDecoration(
                color: appBarBg.withOpacity(0.8),
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, size: 24, color: textPrimary),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                  Expanded(
                    child: Text(
                      "Grammar History",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A90E2),
                      ),
                    )
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading history',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _loadHistory(),
                            child: Text(
                              'Try Again',
                              style: GoogleFonts.lexend(
                                color: const Color(0xFF4A90E2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _grammarHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No grammar checks yet',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start checking your grammar!',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadHistory(page: 0),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _grammarHistory.length,
                        itemBuilder: (context, index) {
                          final grammar = _grammarHistory[index];
                          return _buildHistoryCard(grammar);
                        },
                      ),
                    ),
            ),

            // Pagination
            if (!_isLoading && _grammarHistory.isNotEmpty && _totalPages > 1)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 0
                          ? () => _loadHistory(page: _currentPage - 1)
                          : null,
                    ),
                    Text(
                      'Page ${_currentPage + 1} of $_totalPages',
                      style: GoogleFonts.lexend(fontSize: 14),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentPage < _totalPages - 1
                          ? () => _loadHistory(page: _currentPage + 1)
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Grammar grammar) {
    final scoreColor = _getScoreColor(grammar.score);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Show detail dialog
            _showDetailDialog(grammar);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Score badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: scoreColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.score, size: 16, color: scoreColor),
                          const SizedBox(width: 4),
                          Text(
                            '${grammar.score}/100',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: scoreColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Error count
                    if (grammar.errors.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE94E77).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${grammar.errors.length} errors',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            color: const Color(0xFFE94E77),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Delete button
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () => _showDeleteConfirmDialog(grammar),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Input text preview
                Text(
                  grammar.inputText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                // Date
                Text(
                  dateFormat.format(grammar.createdAt),
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(Grammar grammar) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final sectionBg = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(grammar.score).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Score: ${grammar.score}/100',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getScoreColor(grammar.score),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Original Text
                      Text(
                        'Original Text',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: sectionBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          grammar.inputText,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            color: textColor,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Corrected Text
                      if (grammar.correctedText.isNotEmpty) ...[
                        Text(
                          'Corrected Text',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            grammar.correctedText,
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              color: const Color(0xFF333333),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Errors
                      if (grammar.errors.isNotEmpty) ...[
                        Text(
                          'Errors Found (${grammar.errors.length})',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE94E77),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...grammar.errors.map((error) {
                          final errorColor = _getErrorTypeColor(
                            error.errorType,
                          );
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: errorColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: errorColor.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: errorColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        error.errorType,
                                        style: GoogleFonts.lexend(
                                          fontSize: 11,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.lexend(
                                      fontSize: 13,
                                      color: textColor,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '"${error.errorText}"',
                                        style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: errorColor,
                                        ),
                                      ),
                                      const TextSpan(text: ' → '),
                                      TextSpan(
                                        text: '"${error.correctedText}"',
                                        style: const TextStyle(
                                          color: Color(0xFF7ED321),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (error.explanation.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    error.explanation,
                                    style: GoogleFonts.lexend(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(), // Added .toList() to fix the map usage
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
