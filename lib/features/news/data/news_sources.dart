class NewsFeed {
  final String url;
  final String name;
  const NewsFeed(this.url, this.name);
}

class NewsSources {
  NewsSources._();

  /// ⚠️ VERIFY each URL opens in your browser before shipping.
  /// Feeds move and die. The aggregator skips any that fail.
  static const egypt = <NewsFeed>[
    NewsFeed('https://www.youm7.com/rss/SectionRss?SectionID=297', 'اليوم السابع'),
    NewsFeed('https://www.masrawy.com/rss/rssfeeds?catId=25', 'مصراوي'),
    NewsFeed('https://www.almasryalyoum.com/rss/rssfeeds?sectionId=5', 'المصري اليوم'),
  ];

  static const saudi = <NewsFeed>[
    NewsFeed('https://www.alarabiya.net/.mrss/ar/aswaq.xml', 'العربية'),
    NewsFeed('https://www.aleqt.com/rss', 'الاقتصادية'),
  ];

  static List<NewsFeed> forCurrency(String code) =>
      code == 'SAR' ? saudi : egypt;

  /// Only keep articles that actually mention our topics.
  static const keywords = [
    'ذهب', 'الذهب', 'عيار', 'فضة', 'الفضة',
    'دولار', 'الدولار', 'صرف', 'عملة', 'العملات',
    'أوقية', 'سبائك', 'المعادن',
  ];

  static bool isRelevant(String text) {
    final lower = text.toLowerCase();
    return keywords.any(lower.contains);
  }
}