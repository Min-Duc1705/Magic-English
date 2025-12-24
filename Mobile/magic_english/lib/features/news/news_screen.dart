import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:magic_enlish/core/widgets/common/app_top_bar.dart';
import 'package:magic_enlish/core/widgets/common/app_bottom_nav.dart';
import 'package:magic_enlish/data/services/news_service.dart';
import 'package:magic_enlish/data/models/news/news_article.dart';
import 'package:magic_enlish/features/news/news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  final bool embedded;
  const NewsScreen({super.key, this.embedded = false});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();
  String selectedCategory = "All";
  final List<String> categories = [
    "All",
    "News",
    "Sports",
    "Business",
    "Tech",
    "Travel",
    "Life",
    "World",
  ];

  List<NewsArticle> allArticles = []; // Tất cả bài viết từ RSS
  List<NewsArticle> displayedArticles = []; // Bài viết hiển thị
  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const int articlesPerPage = 5;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && displayedArticles.length < allArticles.length) {
        _loadMoreArticles();
      }
    }
  }

  Future<void> _loadArticles() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      currentPage = 0;
    });

    try {
      final fetchedArticles = await _newsService.fetchArticles(
        selectedCategory,
      );
      setState(() {
        allArticles = fetchedArticles;
        displayedArticles = _getArticlesForPage(0);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load articles. Please try again.';
        isLoading = false;
      });
    }
  }

  List<NewsArticle> _getArticlesForPage(int page) {
    final startIndex = page * articlesPerPage;
    final endIndex = (startIndex + articlesPerPage).clamp(
      0,
      allArticles.length,
    );

    if (startIndex >= allArticles.length) return [];

    return allArticles.sublist(0, endIndex);
  }

  Future<void> _loadMoreArticles() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      currentPage++;
      displayedArticles = _getArticlesForPage(currentPage);
      isLoadingMore = false;
    });
  }

  Future<void> _searchArticles(String query) async {
    if (query.isEmpty) {
      _loadArticles();
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      currentPage = 0;
    });

    try {
      // Gọi API để lấy toàn bộ RSS feed mới và search
      final searchResults = await _newsService.searchArticles(
        query,
        selectedCategory,
      );
      setState(() {
        allArticles = searchResults;
        // Hiển thị tất cả kết quả tìm kiếm (không giới hạn 5 bài)
        displayedArticles = searchResults;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Search failed. Please try again.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If embedded, return just the content without Scaffold and bottom nav
    if (widget.embedded) {
      return _buildContent();
    }

    return Scaffold(
      backgroundColor: const Color(0xfff6f6f8),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            AppTopBar(
              title: "News",
              rightAction: IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {
                  // TODO: Handle bookmark
                },
              ),
            ),

            // Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 5),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _searchArticles,
                      onChanged: (value) {
                        setState(() {}); // Update UI khi text thay đổi
                      },
                      decoration: InputDecoration(
                        hintText: "Search for articles",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _loadArticles();
                      },
                    ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Category Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                      _searchController.clear();
                    });
                    _loadArticles();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4A90E2)
                          : const Color(0xffe8e8e8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: GoogleFonts.lexend(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Loading, Error, or Articles List
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
              ),
            )
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: GoogleFonts.lexend(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadArticles,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                      ),
                      child: Text('Retry', style: GoogleFonts.lexend()),
                    ),
                  ],
                ),
              ),
            )
          else if (displayedArticles.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No articles found',
                  style: GoogleFonts.lexend(color: Colors.grey),
                ),
              ),
            )
          else
            Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedArticles.length,
                  itemBuilder: (context, index) {
                    final article = displayedArticles[index];
                    return _buildArticleCard(article);
                  },
                ),

                // Load More Indicator
                if (isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: Color(0xFF4A90E2)),
                  )
                else if (displayedArticles.length < allArticles.length)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Scroll down to load more (${displayedArticles.length}/${allArticles.length})',
                      style: GoogleFonts.lexend(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  )
                else if (displayedArticles.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'All articles loaded (${displayedArticles.length})',
                      style: GoogleFonts.lexend(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildArticleCard(NewsArticle article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(article: article),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Content
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "VNExpress - ${article.getTimeAgo()}",
                    style: GoogleFonts.lexend(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        "Read more",
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: const Color(0xFF4A90E2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Color(0xFF4A90E2),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: article.imageUrl != null
                  ? Image.network(
                      article.imageUrl!,
                      width: 112,
                      height: 112,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 112,
                          height: 112,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      width: 112,
                      height: 112,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.article, color: Colors.grey),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
