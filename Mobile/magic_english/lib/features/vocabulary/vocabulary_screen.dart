import 'package:flutter/material.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  int _selectedTabIndex = 0; // 0 = My Vocabulary, 1 = News
  int _selectedFilterIndex = 0; // All, A1-A2, B1-B2, C1-C2, Favorites
  final TextEditingController _searchController = TextEditingController();

  // Sample vocabulary data
  final List<VocabularyItem> _vocabularyItems = [
    VocabularyItem(
      word: 'weather',
      partOfSpeech: '(noun/verb)',
      meaning: 'Thời tiết; Vượt qua khó khăn',
      level: 'A1',
      phonetic: '/ˈwɛðər/',
      isFavorite: false,
    ),
    VocabularyItem(
      word: 'storm',
      partOfSpeech: '(noun, verb)',
      meaning: 'Bão tố; Giông bão; Tấn công dữ dội',
      level: 'A2',
      phonetic: '/stɔːm/',
      isFavorite: false,
    ),
    VocabularyItem(
      word: 'six',
      partOfSpeech: '(adjective)',
      meaning: 'Số sáu; Sáu (số lượng)',
      level: 'A1',
      phonetic: '/sɪks/',
      isFavorite: false,
    ),
    VocabularyItem(
      word: 'tropical',
      partOfSpeech: '(adjective)',
      meaning: 'Nhiệt đới; Thuộc vùng nhiệt đới',
      level: 'B1',
      phonetic: '/ˈtrɒpɪkəl/',
      isFavorite: false,
    ),
  ];

  final List<String> _filterOptions = [
    'All',
    'A1-A2',
    'B1-B2',
    'C1-C2',
    'Favorites',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar simulation (optional - usually handled by system)
            _buildStatusBar(isDark),

            // Header
            _buildHeader(isDark),

            // Tab Switcher (My Vocabulary / News)
            _buildTabSwitcher(isDark),

            // Search Bar
            _buildSearchBar(isDark),

            // Filter Chips
            _buildFilterChips(isDark),

            // Vocabulary List
            Expanded(child: _buildVocabularyList(isDark)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(isDark),
    );
  }

  Widget _buildStatusBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '8:02',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.wifi,
                size: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.signal_cellular_alt,
                size: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.battery_full,
                size: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            ),
          ),
          Text(
            'My Vocabulary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                // TODO: Add new word
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.add,
                  size: 24,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 0
                        ? (isDark ? const Color(0xFF4B5563) : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: _selectedTabIndex == 0
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    'My Vocabulary',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _selectedTabIndex == 0
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: _selectedTabIndex == 0
                          ? (isDark ? Colors.white : const Color(0xFF3B82F6))
                          : (isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF6B7280)),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 1
                        ? (isDark ? const Color(0xFF4B5563) : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: _selectedTabIndex == 1
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    'News',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _selectedTabIndex == 1
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: _selectedTabIndex == 1
                          ? (isDark ? Colors.white : const Color(0xFF3B82F6))
                          : (isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF6B7280)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search my words...',
            hintStyle: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _filterOptions.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final isSelected = _selectedFilterIndex == index;
            final isFavorites = index == 4;

            return GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : (isDark ? const Color(0xFF1F2937) : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFF3F4F6),
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (isFavorites) ...[
                      Icon(
                        Icons.star,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFFACC15),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      _filterOptions[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : const Color(0xFF1F2937)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVocabularyList(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _vocabularyItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildVocabularyCard(_vocabularyItems[index], isDark);
      },
    );
  }

  Widget _buildVocabularyCard(VocabularyItem item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    item.word,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.partOfSpeech,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    item.isFavorite = !item.isFavorite;
                  });
                },
                child: Icon(
                  item.isFavorite ? Icons.star : Icons.star_border,
                  color: item.isFavorite
                      ? const Color(0xFFFACC15)
                      : (isDark
                            ? const Color(0xFF4B5563)
                            : const Color(0xFFD1D5DB)),
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Meaning
          Text(
            item.meaning,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 12),

          // Bottom Row: Level badge, Phonetic, More button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Level Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(item.level, isDark),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.level,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getLevelTextColor(item.level, isDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Phonetic
                  Text(
                    item.phonetic,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Show more options
                },
                child: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: isDark
                      ? const Color(0xFF6B7280)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level, bool isDark) {
    switch (level) {
      case 'A1':
      case 'A2':
        return isDark ? const Color(0xFF166534) : const Color(0xFFDCFCE7);
      case 'B1':
      case 'B2':
        return isDark ? const Color(0xFF1E40AF) : const Color(0xFFDBEAFE);
      case 'C1':
      case 'C2':
        return isDark ? const Color(0xFF7C2D12) : const Color(0xFFFED7AA);
      default:
        return isDark ? const Color(0xFF166534) : const Color(0xFFDCFCE7);
    }
  }

  Color _getLevelTextColor(String level, bool isDark) {
    switch (level) {
      case 'A1':
      case 'A2':
        return isDark ? const Color(0xFF86EFAC) : const Color(0xFF16A34A);
      case 'B1':
      case 'B2':
        return isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB);
      case 'C1':
      case 'C2':
        return isDark ? const Color(0xFFFDBA74) : const Color(0xFFEA580C);
      default:
        return isDark ? const Color(0xFF86EFAC) : const Color(0xFF16A34A);
    }
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 20, left: 8, right: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', 0, isDark),
          _buildNavItem(Icons.school, 'Vocab', 1, isDark, isSelected: true),
          _buildNavItem(Icons.text_fields, 'Grammar', 2, isDark),
          _buildNavItem(Icons.fitness_center, 'Practice', 3, isDark),
          _buildNavItem(Icons.bar_chart, 'Progress', 4, isDark),
          _buildNavItem(Icons.person, 'Profile', 5, isDark),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    bool isDark, {
    bool isSelected = false,
  }) {
    const selectedColor = Color(0xFF3B82F6);
    final unselectedColor = isDark
        ? const Color(0xFF6B7280)
        : const Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to corresponding screen
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E3A8A).withOpacity(0.3)
                    : const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: selectedColor),
            )
          else
            Icon(icon, size: 24, color: unselectedColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? selectedColor : unselectedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class VocabularyItem {
  final String word;
  final String partOfSpeech;
  final String meaning;
  final String level;
  final String phonetic;
  bool isFavorite;

  VocabularyItem({
    required this.word,
    required this.partOfSpeech,
    required this.meaning,
    required this.level,
    required this.phonetic,
    this.isFavorite = false,
  });
}
