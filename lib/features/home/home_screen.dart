import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/localization/app_localizations.dart';
import '../../providers/quote_provider.dart';
import '../../providers/premium_provider.dart';
import '../../data/models/quote_model.dart';
import '../../services/ad_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isAnimating = false;
  int _quoteViewCount = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadNextQuote(QuoteProvider provider) async {
    if (_isAnimating) return;

    setState(() => _isAnimating = true);

    // Track quote views for interstitial ad
    _quoteViewCount++;
    if (_quoteViewCount >= 5) {
      _quoteViewCount = 0;
      final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
      if (!premiumProvider.isPremium) {
        final adService = Provider.of<AdService>(context, listen: false);
        adService.showInterstitialAd();
      }
    }

    await _animationController.forward();
    provider.loadNextQuote();
    await _animationController.reverse();

    setState(() => _isAnimating = false);
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
    final premiumProvider = Provider.of<PremiumProvider>(context);
    final quote = quoteProvider.quoteOfTheDay;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showAds = !premiumProvider.isPremium && (Platform.isAndroid || Platform.isIOS);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                    const Color(0xFF0f3460),
                  ]
                : [
                    const Color(0xFF667eea),
                    const Color(0xFF764ba2),
                    const Color(0xFFf093fb),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.appName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () => _loadNextQuote(quoteProvider),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2),
                  ],
                ),
              ),

              // Quote of the Day Label
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.quoteOfTheDay,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
              ),

              // Main Quote Card
              Expanded(
                child: Center(
                  child: quote != null
                      ? AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: 1 - _animationController.value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * _animationController.value),
                                child: child,
                              ),
                            );
                          },
                          child: _buildQuoteCard(context, quote, isArabic, quoteProvider, l10n),
                        )
                      : const CircularProgressIndicator(color: Colors.white),
                ),
              ),

              // Action Buttons
              if (quote != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        icon: quoteProvider.isFavorite(quote.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: quoteProvider.isFavorite(quote.id)
                            ? Colors.red
                            : Colors.white,
                        onTap: () => quoteProvider.toggleFavorite(quote),
                        label: l10n.favorites,
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                      const SizedBox(width: 24),
                      _buildActionButton(
                        icon: Icons.copy_rounded,
                        color: Colors.white,
                        onTap: () => _copyToClipboard(context, quote, l10n),
                        label: l10n.copy,
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                      const SizedBox(width: 24),
                      _buildActionButton(
                        icon: Icons.share_rounded,
                        color: Colors.white,
                        onTap: () => _shareQuote(context, quote),
                        label: l10n.share,
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                      const SizedBox(width: 24),
                      _buildActionButton(
                        icon: Icons.arrow_forward_rounded,
                        color: Colors.white,
                        onTap: () => _loadNextQuote(quoteProvider),
                        label: l10n.next,
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
                    ],
                  ),
                ),

              // Banner Ad
              if (showAds) _BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteCard(BuildContext context, Quote quote, bool isArabic, QuoteProvider provider, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quote Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.format_quote_rounded,
              color: Colors.white,
              size: 28,
            ),
          ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.5, 0.5)),

          const SizedBox(height: 24),

          // Quote Text
          Text(
            isArabic ? quote.textAr : quote.text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

          const SizedBox(height: 24),

          // Divider
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0, 1)),

          const SizedBox(height: 16),

          // Author
          Text(
            '— ${isArabic ? quote.authorAr : quote.author}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
        ],
      ),
    ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.1);
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Icon(icon, color: color, size: 26),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _BannerAdWidget extends StatefulWidget {
  @override
  State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adService = Provider.of<AdService>(context, listen: false);
    if (adService.isBannerAdLoaded && adService.bannerAd != null) {
      setState(() {
        _bannerAd = adService.bannerAd;
        _isAdLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox(height: 50);
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
