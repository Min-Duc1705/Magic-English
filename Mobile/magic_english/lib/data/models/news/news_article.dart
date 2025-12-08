class NewsArticle {
  final String title;
  final String description;
  final String link;
  final String? imageUrl;
  final DateTime? pubDate;
  final String? category;
  final String? fullContent; // Nội dung đầy đủ từ RSS
  final String? author; // Tác giả bài báo

  NewsArticle({
    required this.title,
    required this.description,
    required this.link,
    this.imageUrl,
    this.pubDate,
    this.category,
    this.fullContent,
    this.author,
  });

  factory NewsArticle.fromRssItem(dynamic item) {
    // Extract image from description or media content
    String? imageUrl;
    String description = item.description ?? '';
    String? fullContent;
    String? author;

    // Try to extract image from description (VNExpress embeds images in description)
    final imgRegex = RegExp(r'<img[^>]+src="([^">]+)"');
    final match = imgRegex.firstMatch(description);
    if (match != null) {
      imageUrl = match.group(1);
    }

    // Extract full content from content:encoded if available (RSS 2.0)
    if (item.content != null && item.content.value != null) {
      fullContent = item.content.value
          .replaceAll(RegExp(r'<[^>]*>'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    }

    // Try to extract author from various RSS fields
    // VNExpress might include author in dc:creator or author field
    if (item.dc?.creator != null && item.dc.creator.isNotEmpty) {
      author = item.dc.creator;
    } else if (item.author != null && item.author.isNotEmpty) {
      author = item.author;
    }

    // If still no author, try to extract from title or content
    // VNExpress sometimes includes author at the end: "- Author Name"
    if (author == null && fullContent != null) {
      final authorMatch = RegExp(
        r'-\s*([A-Z][a-zA-Z\s]+)\s*$',
      ).firstMatch(fullContent);
      if (authorMatch != null) {
        author = authorMatch.group(1)?.trim();
      }
    }

    // Clean HTML from description
    final cleanDesc = description
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return NewsArticle(
      title: item.title ?? 'No title',
      description: cleanDesc.isNotEmpty ? cleanDesc : 'No description',
      link: item.link ?? '',
      imageUrl: imageUrl,
      pubDate: item.pubDate,
      category: item.categories?.isNotEmpty == true
          ? item.categories!.first.value
          : null,
      fullContent: fullContent,
      author: author,
    );
  }

  String getTimeAgo() {
    if (pubDate == null) return 'Unknown time';

    final now = DateTime.now();
    final difference = now.difference(pubDate!);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
