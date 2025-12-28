import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import '../models/news/news_article.dart';

class NewsService {
  // VNExpress International RSS feeds
  static const String _baseUrl = 'https://e.vnexpress.net/rss';

  static const Map<String, String> categoryFeeds = {
    'All': '$_baseUrl/home.rss',
    'News': '$_baseUrl/news.rss',
    'Business': '$_baseUrl/business.rss',
    'Tech': '$_baseUrl/tech.rss',
    'Travel': '$_baseUrl/travel.rss',
    'Life': '$_baseUrl/life.rss',
    'Sports': '$_baseUrl/sports.rss',
    'World': '$_baseUrl/world.rss',
  };

  /// Fetch articles from RSS feed by category
  Future<List<NewsArticle>> fetchArticles(String category) async {
    try {
      final feedUrl = categoryFeeds[category] ?? categoryFeeds['All']!;

      final response = await http.get(Uri.parse(feedUrl));

      if (response.statusCode == 200) {
        // Parse RSS feed
        final feed = RssFeed.parse(response.body);

        // Convert RSS items to NewsArticle objects
        final articles =
            feed.items?.map((item) {
              return NewsArticle.fromRssItem(item);
            }).toList() ??
            [];

        return articles;
      } else {
        throw Exception('Failed to load RSS feed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching articles: $e');
      throw Exception('Failed to fetch articles: $e');
    }
  }

  /// Search articles by keyword
  Future<List<NewsArticle>> searchArticles(
    String query,
    String category,
  ) async {
    final articles = await fetchArticles(category);

    if (query.isEmpty) return articles;

    final lowercaseQuery = query.toLowerCase();
    return articles.where((article) {
      return article.title.toLowerCase().contains(lowercaseQuery) ||
          article.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get latest articles (default: All category)
  Future<List<NewsArticle>> getLatestNews() async {
    return fetchArticles('All');
  }
}
