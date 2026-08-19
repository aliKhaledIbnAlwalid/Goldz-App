import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/news_repository.dart';
import '../../domain/entities/news_article.dart';

class NewsState extends Equatable {
  final List<NewsArticle> articles;
  final bool isLoading;
  final String? currencyCode;

  const NewsState({
    this.articles = const [],
    this.isLoading = false,
    this.currencyCode,
  });

  @override
  List<Object?> get props => [articles, isLoading, currencyCode];
}

class NewsCubit extends Cubit<NewsState> {
  final NewsRepository repository;
  NewsCubit(this.repository) : super(const NewsState());

  Future<void> load(String currencyCode,
      {bool forceRefresh = false}) async {
    // Already have this country's news — don't refetch on every rebuild.
    if (!forceRefresh &&
        state.currencyCode == currencyCode &&
        state.articles.isNotEmpty) {
      return;
    }

    emit(NewsState(
      articles: state.currencyCode == currencyCode ? state.articles : const [],
      isLoading: true,
      currencyCode: currencyCode,
    ));

    final articles =
        await repository.getNews(currencyCode, forceRefresh: forceRefresh);

    emit(NewsState(
      articles: articles,
      isLoading: false,
      currencyCode: currencyCode,
    ));
  }
}