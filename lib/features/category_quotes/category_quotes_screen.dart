import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/models/quote_model.dart';
import '../../providers/quote_provider.dart';

class CategoryQuotesScreen extends StatefulWidget {
  final String categoryName;
  final String categoryValue;
  final Color categoryColor;
  final IconData categoryIcon;

  const CategoryQuotesScreen({
    super.key,
    required this.categoryName,
    required this.categoryValue,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  State<CategoryQuotesScreen> createState() => _CategoryQuotesScreenState();
}

class _CategoryQuotesScreenState extends State<CategoryQuotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<QuoteProvider>(context, listen: false);
      provider.loadQuotesByCategory(widget.categoryValue);
    });
  }

  void _copyToClipboard(BuildContext context, Quote quote, AppLocalizations l10n) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final text = isArabic
        ? '${quote.textAr}\n- ${quote.authorAr}'
        : '${quote.text}\n- ${quote.author}';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.copiedToClipboard),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareQuote(BuildContext context, Quote quote) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final text = isArabic
        ? '${quote.textAr}\n- ${quote.authorAr}\n\n✨ via Quotezia'
        : '${quote.text}\n- ${quote.author}\n\n✨ via Quotezia';

    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quoteProvider = Provider.of<QuoteProvider>(context);
    final quotes = quoteProvider.categoryQuotes;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Back Button
                    Container(
                      decoration: BoxDecoration(
                        color: widget.categoryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: widget.categoryColor,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.3),

                    const SizedBox(width: 16),

                    // Title Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: widget.categoryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  widget.categoryIcon,
                                  color: widget.categoryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                widget.categoryName,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${quotes.length} ${l10n.quotes}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                    ),
                  ],
                ),
              ),

              // Quotes List
              Expanded(
                child: quoteProvider.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: widget.categoryColor,
                        ),
                      )
                    : quotes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.format_quote,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No quotes found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: quotes.length,
                            itemBuilder: (context, index) {
                              final quote = quotes[index];
                              return _QuoteCard(
                                quote: quote,
                                isArabic: isArabic,
                                categoryColor: widget.categoryColor,
                                isFavorite: quoteProvider.isFavorite(quote.id),
                                onFavorite: () => quoteProvider.toggleFavorite(quote),
                                onCopy: () => _copyToClipboard(context, quote, l10n),
                                onShare: () => _shareQuote(context, quote),
                              )
                                  .animate()
                                  .fadeIn(delay: (50 * index).ms, duration: 300.ms)
                                  .slideX(begin: 0.1, delay: (50 * index).ms);
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

class _QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isArabic;
  final Color categoryColor;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _QuoteCard({
    required this.quote,
    required this.isArabic,
    required this.categoryColor,
    required this.isFavorite,
    required this.onFavorite,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quote Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.format_quote,
                color: categoryColor,
                size: 20,
              ),
            ),

            const SizedBox(height: 16),

            // Quote Text
            Text(
              isArabic ? quote.textAr : quote.text,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: isDark ? Colors.grey[200] : Colors.grey[800],
                fontStyle: FontStyle.italic,
              ),
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            ),

            const SizedBox(height: 16),

            // Author
            Text(
              '— ${isArabic ? quote.authorAr : quote.author}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: categoryColor,
              ),
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            ),

            const SizedBox(height: 16),

            // Divider
            Divider(
              color: isDark ? Colors.grey[700] : Colors.grey[200],
            ),

            const SizedBox(height: 8),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : (isDark ? Colors.grey[400]! : Colors.grey[600]!),
                  onTap: onFavorite,
                ),
                _ActionButton(
                  icon: Icons.copy_rounded,
                  color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  onTap: onCopy,
                ),
                _ActionButton(
                  icon: Icons.share_rounded,
                  color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  onTap: onShare,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
