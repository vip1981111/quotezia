import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/premium_provider.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  void _showSuccessDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.unlockPremium,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to Premium!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _handlePurchase(
    BuildContext context,
    PremiumProvider premiumProvider,
    AppLocalizations l10n,
  ) async {
    _showLoadingDialog(context);

    // Simulate purchase for testing
    await premiumProvider.simulatePurchase();

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
      _showSuccessDialog(context, l10n);
    }
  }

  Future<void> _handleRestore(
    BuildContext context,
    PremiumProvider premiumProvider,
    AppLocalizations l10n,
  ) async {
    _showLoadingDialog(context);

    await premiumProvider.restorePurchases();

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            premiumProvider.isPremium
                ? 'Purchases restored successfully!'
                : 'No previous purchases found',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final premiumProvider = Provider.of<PremiumProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (premiumProvider.isPremium) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.premium),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  size: 64,
                  color: Colors.white,
                ),
              ).animate().scale(duration: 500.ms),
              const SizedBox(height: 24),
              Text(
                'You are Premium!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                'Enjoy all premium features',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
              ).animate().fadeIn(delay: 300.ms),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.premium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Premium Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryLight,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 64,
                color: Colors.white,
              ),
            ).animate().scale(duration: 500.ms),
            const SizedBox(height: 24),

            // Title
            Text(
              l10n.unlockPremium,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 32),

            // Features
            _FeatureItem(
              icon: Icons.block,
              title: l10n.adFreeExperience,
              description: l10n.adFreeDescription,
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
            _FeatureItem(
              icon: Icons.all_inclusive,
              title: l10n.unlimitedQuotes,
              description: l10n.unlimitedQuotesDescription,
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
            _FeatureItem(
              icon: Icons.notifications_active,
              title: l10n.customNotifications,
              description: l10n.customNotificationsDescription,
            ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2),
            _FeatureItem(
              icon: Icons.category,
              title: l10n.exclusiveCategories,
              description: l10n.exclusiveCategoriesDescription,
            ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2),

            const SizedBox(height: 32),

            // Pricing Options
            _PricingCard(
              title: l10n.monthly,
              price: '\$2.99',
              period: l10n.perMonth,
              isPopular: false,
              isLoading: premiumProvider.isLoading,
              onTap: () => _handlePurchase(context, premiumProvider, l10n),
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
            const SizedBox(height: 12),
            _PricingCard(
              title: l10n.yearly,
              price: '\$19.99',
              period: l10n.perYear,
              isPopular: true,
              popularLabel: l10n.popular,
              savings: l10n.save44,
              isLoading: premiumProvider.isLoading,
              onTap: () => _handlePurchase(context, premiumProvider, l10n),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
            const SizedBox(height: 12),
            _PricingCard(
              title: l10n.lifetime,
              price: '\$49.99',
              period: l10n.oneTime,
              isPopular: false,
              isLoading: premiumProvider.isLoading,
              onTap: () => _handlePurchase(context, premiumProvider, l10n),
            ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2),

            const SizedBox(height: 24),

            // Restore Purchases
            TextButton(
              onPressed: premiumProvider.isLoading
                  ? null
                  : () => _handleRestore(context, premiumProvider, l10n),
              child: Text(l10n.restorePurchases),
            ).animate().fadeIn(delay: 1000.ms),

            const SizedBox(height: 16),

            // Note about test mode
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Test Mode: Purchases are simulated',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1100.ms),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final bool isPopular;
  final String? savings;
  final String? popularLabel;
  final bool isLoading;
  final VoidCallback onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    required this.isPopular,
    this.savings,
    this.popularLabel,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPopular
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (isPopular && popularLabel != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              popularLabel!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (savings != null)
                      Text(
                        savings!,
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    period,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
