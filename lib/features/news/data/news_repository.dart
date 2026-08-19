import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:xml/xml.dart';

import '../domain/entities/news_article.dart';
import 'news_sources.dart';

class NewsRepository {
  final Dio dio;
  final Box box;

  NewsRepository({required this.dio, required this.box});

  static const _ttl = Duration(minutes: 30);
  static const _maxArticles = 30;

  String _key(String currency) => 'news_$currency';
  String _keyAt(String currency) => 'news_at_$currency';

  Future<List<NewsArticle>> getNews(
    String currencyCode, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _isFresh(currencyCode)) {
      final cached = _readCache(currencyCode);
      if (cached.isNotEmpty) return cached;
    }

    final feeds = NewsSources.forCurrency(currencyCode);

    // All feeds in parallel — a dead one can't block the rest.
    final results =
        await Future.wait(feeds.map(_fetchFeed), eagerError: false);

    final articles = <NewsArticle>[];
    for (final list in results) {
      articles.addAll(list);
    }

    if (articles.isEmpty) return _readCache(currencyCode);

    // De-duplicate — the same story often runs on several outlets.
    final seen = <String>{};
    final unique = articles.where((a) => seen.add(a.link)).toList();

    unique.sort((a, b) {
      final aDate = a.publishedAt ?? DateTime(1970);
      final bDate = b.publishedAt ?? DateTime(1970);
      return bDate.compareTo(aDate);
    });

    final trimmed = unique.take(_maxArticles).toList();
    await _writeCache(currencyCode, trimmed);
    return trimmed;
  }

  Future<List<NewsArticle>> _fetchFeed(NewsFeed feed) async {
    try {
      final response = await dio.get(
        feed.url,
        // Bytes, not plain: Arabic feeds vary in encoding and Dio's
        // automatic decoding mangles them.
        options: Options(responseType: ResponseType.bytes),
      );

      final body = utf8.decode(
        response.data as List<int>,
        allowMalformed: true,
      );

      final document = XmlDocument.parse(body);

      // RSS 2.0 uses <item>, Atom uses <entry>. Support both.
      final rssItems = document.findAllElements('item');
      final items = rssItems.isNotEmpty
          ? rssItems
          : document.findAllElements('entry');

      final articles = <NewsArticle>[];

      for (final item in items) {
        final title = _text(item, 'title');
        final link = _link(item);
        final summary = _text(item, 'description').isNotEmpty
            ? _text(item, 'description')
            : _text(item, 'summary');

        if (title.isEmpty || link.isEmpty) continue;
        if (!NewsSources.isRelevant('$title $summary')) continue;

        articles.add(NewsArticle(
          title: _clean(title),
          summary: _clean(summary),
          link: link,
          source: feed.name,
          publishedAt: _parseDate(
            _text(item, 'pubDate').isNotEmpty
                ? _text(item, 'pubDate')
                : _text(item, 'published').isNotEmpty
                    ? _text(item, 'published')
                    : _text(item, 'updated'),
          ),
        ));
      }

      return articles;
    } catch (_) {
      // Dead or malformed feed — skip silently, others still work.
      return const [];
    }
  }

  String _text(XmlElement item, String tag) {
    try {
      final element = item.findElements(tag).firstOrNull;
      return element?.innerText.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  /// RSS puts the URL in the element text; Atom puts it in href.
  String _link(XmlElement item) {
    final element = item.findElements('link').firstOrNull;
    if (element == null) return '';

    final href = element.getAttribute('href');
    if (href != null && href.isNotEmpty) return href;

    return element.innerText.trim();
  }

  String _clean(String raw) {
    final noHtml = raw.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final noEntities = noHtml
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    final collapsed = noEntities.replaceAll(RegExp(r'\s+'), ' ').trim();
    return collapsed.length > 180
        ? '${collapsed.substring(0, 180)}…'
        : collapsed;
  }

  DateTime? _parseDate(String raw) {
    if (raw.isEmpty) return null;

    // Atom uses ISO-8601, which parses directly.
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso.toLocal();

    // RSS uses RFC-822: "Tue, 19 Aug 2026 14:30:00 +0200"
    final match = RegExp(r'(\d{1,2})\s+(\w{3})\s+(\d{4})').firstMatch(raw);
    if (match == null) return null;

    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    final month = months[match.group(2)];
    if (month == null) return null;

    final time = RegExp(r'(\d{2}):(\d{2})').firstMatch(raw);

    return DateTime(
      int.parse(match.group(3)!),
      month,
      int.parse(match.group(1)!),
      time == null ? 0 : int.parse(time.group(1)!),
      time == null ? 0 : int.parse(time.group(2)!),
    );
  }

  // ─────────── cache ───────────

  bool _isFresh(String currency) {
    final raw = box.get(_keyAt(currency));
    final at = raw is String ? DateTime.tryParse(raw) : null;
    if (at == null) return false;
    return DateTime.now().difference(at) < _ttl;
  }

  List<NewsArticle> _readCache(String currency) {
    final raw = box.get(_key(currency));
    if (raw is! String) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map>()
          .map((m) => NewsArticle(
                title: m['t']?.toString() ?? '',
                summary: m['s']?.toString() ?? '',
                link: m['l']?.toString() ?? '',
                source: m['src']?.toString() ?? '',
                publishedAt: DateTime.tryParse(m['d']?.toString() ?? ''),
              ))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _writeCache(
      String currency, List<NewsArticle> articles) async {
    try {
      final encoded = jsonEncode(articles
          .map((a) => {
                't': a.title,
                's': a.summary,
                'l': a.link,
                'src': a.source,
                'd': a.publishedAt?.toIso8601String(),
              })
          .toList());
      await box.putAll({
        _key(currency): encoded,
        _keyAt(currency): DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Cache failure never breaks the feature.
    }
  }
}