import 'package:equatable/equatable.dart';

class NewsArticle extends Equatable {
  final String title;
  final String summary;
  final String link;
  final String source;
  final DateTime? publishedAt;

  const NewsArticle({
    required this.title,
    required this.summary,
    required this.link,
    required this.source,
    required this.publishedAt,
  });

  @override
  List<Object?> get props => [link];
}