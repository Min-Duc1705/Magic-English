import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/widgets/common/app_bottom_nav.dart';
import 'package:magic_enlish/core/widgets/profile/stats_grid.dart';
import 'package:magic_enlish/core/widgets/home/action_cards_section.dart';
import 'package:magic_enlish/core/widgets/vocabulary/recent_words_section.dart';
import 'package:magic_enlish/features/vocabulary/add_word_screen.dart';
import 'package:magic_enlish/features/vocabulary/vocabulary_screen.dart';
import 'package:magic_enlish/features/grammar_checker/grammar_checker_screen.dart';
import 'package:provider/provider.dart';
import 'package:magic_enlish/providers/auth/auth_provider.dart';
import 'package:magic_enlish/providers/vocabulary/vocabulary_provider.dart';
import 'package:magic_enlish/providers/home/home_stats_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color get primary => const Color(0xff3713ec);

  @override
  void initState() {
    super.initState();
    // Load recent words and home stats when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vocabularyProvider = Provider.of<VocabularyProvider>(
        context,
        listen: false,
      );
      vocabularyProvider.loadVocabularies(reset: true);

      final homeStatsProvider = Provider.of<HomeStatsProvider>(
        context,
        listen: false,
      );
      homeStatsProvider.loadHomeStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vocabularyProvider = Provider.of<VocabularyProvider>(context);
    final homeStatsProvider = Provider.of<HomeStatsProvider>(context);

    // Get 3 newest words (sorted by createdAt descending)
    final allVocabs = vocabularyProvider.vocabularies.toList();
    allVocabs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recentWords = allVocabs.take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xfff6f6f8),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- TOP BAR ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.auto_stories, color: primary, size: 32),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        final displayName = auth.user?.name ?? 'Guest';
                        return Text(
                          "Hello, $displayName!",
                          style: GoogleFonts.lexend(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: Colors.black),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // -------- MAIN CONTENT --------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------- 4 STAT CARDS --------
                    StatsGrid(
                      streakDays: homeStatsProvider.streakDays,
                      wordsToday: homeStatsProvider.wordsToday,
                      masteredWords: homeStatsProvider.grammarChecks,
                      quizScore: homeStatsProvider.avgGrammarScore,
                      quizTotal: 100,
                      cardTitles: const [
                        'Learning ',
                        'Vocabulary',
                        'Grammar Check',
                        'Grammar Score ',
                      ],
                      cardSubtitles: const [
                        'Streak',
                        'Today',
                        'Today',
                        'Avg Today',
                      ],
                    ),

                    const SizedBox(height: 24),

                    // -------- ACTION CARDS --------
                    ActionCardsSection(
                      primaryColor: primary,
                      onAddNewWord: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddWordPage(),
                          ),
                        );
                      },
                      onReviewWords: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VocabularyPage(),
                          ),
                        );
                      },
                      onCheckText: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GrammarCheckerPage(),
                          ),
                        );
                      },
                      onViewProgress: () {
                        // TODO: Create progress screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Progress Dashboard coming soon!',
                              style: GoogleFonts.lexend(),
                            ),
                            backgroundColor: primary,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // -------- RECENT WORDS --------
                    RecentWordsSection(
                      recentWords: recentWords,
                      isLoading: vocabularyProvider.isLoading,
                      error: vocabularyProvider.error,
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
