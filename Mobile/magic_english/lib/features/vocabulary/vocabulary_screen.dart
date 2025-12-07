import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/providers/vocabulary/vocabulary_provider.dart';
import 'package:provider/provider.dart';
import 'package:magic_enlish/core/widgets/common/app_bottom_nav.dart';
import 'package:magic_enlish/core/widgets/common/search_bar_widget.dart';
import 'package:magic_enlish/core/widgets/vocabulary/filter_chip_widget.dart';
import 'package:magic_enlish/core/widgets/vocabulary/vocabulary_card_widget.dart';
import 'package:magic_enlish/features/vocabulary/add_word_screen.dart';
import 'package:magic_enlish/features/vocabulary/review_word_screen.dart';
import 'package:magic_enlish/features/news/news_screen.dart';

class VocabularyPage extends StatefulWidget {
  const VocabularyPage({super.key});

  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedTab = "My Vocabulary";

  Color get primary => const Color(0xFF4A90E2);
  Color get background => const Color(0xfff6f6f8);

  @override
  void initState() {
    super.initState();
    // Clear search khi vào trang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchController.clear();
        context.read<VocabularyProvider>().searchVocabularies('');
      }
    });

    // Listen to scroll để load more
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Khi còn 200px nữa là đến cuối, load more
      context.read<VocabularyProvider>().loadMoreVocabularies();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            // -------------------- TOP BAR --------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/home'),
                    child: const Icon(Icons.arrow_back, size: 28),
                  ),
                  const Spacer(),
                  Text(
                    "My Vocabulary",
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddWordPage()),
                      );
                      if (result == true && mounted) {
                        context.read<VocabularyProvider>().loadVocabularies();
                      }
                    },
                    child: const Icon(Icons.add, size: 28),
                  ),
                ],
              ),
            ),

            // -------------------- SEGMENTED BUTTONS --------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = "My Vocabulary";
                          });
                        },
                        child: Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: _selectedTab == "My Vocabulary"
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: _selectedTab == "My Vocabulary"
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              "My Vocabulary",
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _selectedTab == "My Vocabulary"
                                    ? const Color(0xFF333333)
                                    : const Color(0xFF999999),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = "News";
                          });
                        },
                        child: Container(
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: _selectedTab == "News"
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: _selectedTab == "News"
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              "News",
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _selectedTab == "News"
                                    ? const Color(0xFF333333)
                                    : const Color(0xFF999999),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // -------------------- SEARCH BAR --------------------
            if (_selectedTab == "My Vocabulary")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SearchBarWidget(
                  hintText: "Search my words...",
                  controller: _searchController,
                  onChanged: (query) {
                    context.read<VocabularyProvider>().searchVocabularies(
                      query,
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),
            // -------------------- FILTER TABS --------------------
            if (_selectedTab == "My Vocabulary")
              Consumer<VocabularyProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      children: [
                        FilterChipWidget(
                          label: "All",
                          isActive: provider.selectedFilter == "All",
                          onTap: () => provider.setFilter("All"),
                          primaryColor: primary,
                        ),
                        FilterChipWidget(
                          label: "A1-A2",
                          isActive: provider.selectedFilter == "A1-A2",
                          onTap: () => provider.setFilter("A1-A2"),
                          primaryColor: primary,
                        ),
                        FilterChipWidget(
                          label: "B1-B2",
                          isActive: provider.selectedFilter == "B1-B2",
                          onTap: () => provider.setFilter("B1-B2"),
                          primaryColor: primary,
                        ),
                        FilterChipWidget(
                          label: "C1-C2",
                          isActive: provider.selectedFilter == "C1-C2",
                          onTap: () => provider.setFilter("C1-C2"),
                          primaryColor: primary,
                        ),
                        FilterChipWidget(
                          label: "Favorites",
                          isActive: provider.selectedFilter == "Favorites",
                          onTap: () => provider.setFilter("Favorites"),
                          icon: Icons.star,
                          primaryColor: primary,
                        ),
                      ],
                    ),
                  );
                },
              ),

            // -------------------- VOCAB LIST / EXPLORE --------------------
            Expanded(
              child: _selectedTab == "My Vocabulary"
                  ? Consumer<VocabularyProvider>(
                      builder: (context, provider, _) {
                        return _buildVocabularyList(provider);
                      },
                    )
                  : _buildNewsView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVocabularyList(VocabularyProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error: ${provider.error}',
              style: GoogleFonts.lexend(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadVocabularies(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.vocabularies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No vocabulary found',
              style: GoogleFonts.lexend(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first word!',
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount:
          provider.vocabularies.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the end
        if (index == provider.vocabularies.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final vocab = provider.vocabularies[index];
        return VocabularyCardWidget(
          vocabulary: vocab,
          isFavorite: provider.isFavorite(vocab.id),
          onFavoriteTap: () {
            if (vocab.id != null) {
              provider.toggleFavorite(vocab.id!);
            }
          },
          onMoreTap: () {
            _showVocabularyOptions(context, vocab);
          },
          onTap: () {
            _navigateToVocabularyDetail(context, provider.vocabularies, index);
          },
          primaryColor: primary,
        );
      },
    );
  }

  Widget _buildNewsView() {
    return const NewsScreen(embedded: true);
  }

  void _navigateToVocabularyDetail(
    BuildContext context,
    List<dynamic> vocabularies,
    int currentIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _VocabularyNavigator(
          vocabularies: vocabularies,
          initialIndex: currentIndex,
        ),
      ),
    );
  }

  void _showVocabularyOptions(BuildContext context, vocab) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text('Edit', style: GoogleFonts.lexend()),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete',
                style: GoogleFonts.lexend(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement delete functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Navigator widget for vocabulary detail with next word functionality
class _VocabularyNavigator extends StatefulWidget {
  final List<dynamic> vocabularies;
  final int initialIndex;

  const _VocabularyNavigator({
    required this.vocabularies,
    required this.initialIndex,
  });

  @override
  State<_VocabularyNavigator> createState() => _VocabularyNavigatorState();
}

class _VocabularyNavigatorState extends State<_VocabularyNavigator> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void _goToNextWord() {
    if (currentIndex < widget.vocabularies.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      // Last word, go back
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VocabularyDetailScreen(
      vocabulary: widget.vocabularies[currentIndex],
      showNextButton: true,
      onNextWord: _goToNextWord,
    );
  }
}
