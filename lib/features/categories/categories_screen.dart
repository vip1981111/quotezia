import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/quote_model.dart';
import '../../providers/quote_provider.dart';
import '../category_quotes/category_quotes_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quoteProvider = Provider.of<QuoteProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      _CategoryItem(
        title: l10n.motivation,
        icon: Icons.rocket_launch,
        color: AppColors.categoryMotivation,
        category: QuoteCategory.motivation,
      ),
      _CategoryItem(
        title: l10n.success,
        icon: Icons.emoji_events,
        color: AppColors.categorySuccess,
        category: QuoteCategory.success,
      ),
      _CategoryItem(
        title: l10n.wisdom,
        icon: Icons.lightbulb,
        color: AppColors.categoryWisdom,
        category: QuoteCategory.wisdom,
      ),
      _CategoryItem(
        title: l10n.life,
        icon: Icons.nature,
        color: AppColors.categoryLife,
        category: QuoteCategory.life,
      ),
      _CategoryItem(
        title: l10n.faith,
        icon: Icons.auto_awesome,
        color: AppColors.categoryFaith,
        category: QuoteCategory.faith,
      ),
      _CategoryItem(
        title: l10n.love,
        icon: Icons.favorite,
        color: AppColors.categoryLove,
        category: QuoteCategory.love,
      ),
      _CategoryItem(
        title: l10n.happiness,
        icon: Icons.sentiment_very_satisfied,
        color: AppColors.categoryHappiness,
        category: QuoteCategory.happiness,
      ),
      _CategoryItem(
        title: l10n.friendship,
        icon: Icons.people,
        color: AppColors.categoryFriendship,
        category: QuoteCategory.friendship,
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE2E8F0),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.categories,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                    const SizedBox(height: 8),
                    Text(
                      '${quoteProvider.totalQuotes} ${l10n.quotes}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  ],
                ),
              ),

              // Categories Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final quoteCount = quoteProvider.getQuoteCountForCategory(
                      category.category.value,
                    );
                    return _CategoryCard(
                      category: category,
                      quoteCount: quoteCount,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryQuotesScreen(
                              categoryName: category.title,
                              categoryValue: category.category.value,
                              categoryColor: category.color,
                              categoryIcon: category.icon,
                            ),
                          ),
                        );
                      },
                    )
                        .animate()
                        .fadeIn(delay: (100 * index).ms, duration: 400.ms)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          delay: (100 * index).ms,
                          duration: 400.ms,
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String title;
  final IconData icon;
  final Color color;
  final QuoteCategory category;

  _CategoryItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.category,
  });
}

class _CategoryCard extends StatelessWidget {
  final _CategoryItem category;
  final int quoteCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.quoteCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: category.color.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                category.color,
                category.color.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background Pattern
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  category.icon,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon Container
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        category.icon,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),

                    // Title and Count
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$quoteCount',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
