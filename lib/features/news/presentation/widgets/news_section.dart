import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_currencies.dart';
import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_text.dart';
import '../../domain/entities/news_article.dart';
import '../cubit/news_cubit.dart';

class NewsSection extends StatelessWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return BlocBuilder<CurrencyCubit, AppCurrency>(
      builder: (context, currency) {
        // Country follows the selected currency.
        context.read<NewsCubit>().load(currency.code);

        return BlocBuilder<NewsCubit, NewsState>(
          builder: (context, state) {
            if (state.isLoading && state.articles.isEmpty) {
              return SizedBox(
                height: 90,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: c.brass),
                  ),
                ),
              );
            }

            if (state.articles.isEmpty) return const SizedBox.shrink();

            final top = state.articles.take(4).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currency.code == 'SAR'
                      ? 'أخبار السوق السعودي'
                      : 'أخبار السوق المصري',
                  style: AppText.heading(21, color: c.textPrimary),
                ),
                const SizedBox(height: 14),
                ...top.map((article) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _NewsCard(article: article),
                    )),
              ],
            );
          },
        );
      },
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsArticle article;
  const _NewsCard({required this.article});
  Future<void> _open() async {
    final uri = Uri.tryParse(article.link);
    if (uri == null) return;
    try {
      // Opens the publisher's own page — we never republish their text.
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Some devices have no browser handler; fail quietly.
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return InkWell(
      onTap: _open,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(article.source,
                      style: AppText.label(10, color: c.brass,
                          weight: FontWeight.w600)),
                ),
                const Spacer(),
                if (article.publishedAt != null)
                  Text(_ago(article.publishedAt!),
                      style: AppText.label(10.5, color: c.textMuted)),
                const SizedBox(width: 6),
                Icon(Icons.open_in_new_rounded,
                    size: 13, color: c.textMuted),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppText.label(14.5,
                  color: c.textPrimary, weight: FontWeight.w600),
            ),
            if (article.summary.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                article.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.label(12.5, color: c.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _ago(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    return 'منذ ${diff.inDays} ي';
  }
}