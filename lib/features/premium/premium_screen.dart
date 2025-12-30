import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
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

  void _showErrorDialog(BuildContext context, String message) {
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
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Purchase Failed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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

  // Get product by ID from the loaded products
  ProductDetails? _getProductById(List<ProductDetails> products, String productId) {
    try {
      return products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _handlePurchase(
    BuildContext context,
    PremiumProvider premiumProvider,
    AppLocalizations l10n,
    String productId,
  ) async {
    // Check if products are available
    if (premiumProvider.products.isEmpty) {
      _showErrorDialog(
        context,
        'Products are not available. Please try again later.',
      );
      return;
    }

    // Find the product
    final product = _getProductById(premiumProvider.products, productId);
    if (product == null) {
      _showErrorDialog(
        context,
        'This product is not available. Please try again later.',
      );
      return;
    }

    // Start purchase
    final success = await premiumProvider.purchaseProduct(product);

    if (!success && context.mounted) {
      // Purchase was cancelled or failed
      // The actual success handling is done via the purchase stream listener
      // So we only show error if the purchase initiation failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Purchase was cancelled or failed'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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

    // Get real prices from products if available
    final monthlyProduct = _getProductById(premiumProvider.products, AppStrings.premiumMonthlyId);
    final yearlyProduct = _getProductById(premiumProvider.products, AppStrings.premiumYearlyId);
    final lifetimeProduct = _getProductById(premiumProvider.products, AppStrings.premiumLifetimeId);

    final monthlyPrice = monthlyProduct?.price ?? '\$2.99';
    final yearlyPrice = yearlyProduct?.price ?? '\$19.99';
    final lifetimePrice = lifetimeProduct?.price ?? '\$49.99';

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

            // Show message if products not available
            if (premiumProvider.products.isEmpty && !premiumProvider.isLoading)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
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
                        'Products are loading... Please wait or try again later.',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),

            // Pricing Options
            _PricingCard(
              title: l10n.monthly,
              price: monthlyPrice,
              period: l10n.perMonth,
              isPopular: false,
              isLoading: premiumProvider.isLoading,
              isAvailable: monthlyProduct != null,
              onTap: () => _handlePurchase(
                context,
                premiumProvider,
                l10n,
                AppStrings.premiumMonthlyId,
              ),
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
            const SizedBox(height: 12),
            _PricingCard(
              title: l10n.yearly,
              price: yearlyPrice,
              period: l10n.perYear,
              isPopular: true,
              popularLabel: l10n.popular,
              savings: l10n.save44,
              isLoading: premiumProvider.isLoading,
              isAvailable: yearlyProduct != null,
              onTap: () => _handlePurchase(
                context,
                premiumProvider,
                l10n,
                AppStrings.premiumYearlyId,
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
            const SizedBox(height: 12),
            _PricingCard(
              title: l10n.lifetime,
              price: lifetimePrice,
              period: l10n.oneTime,
              isPopular: false,
              isLoading: premiumProvider.isLoading,
              isAvailable: lifetimeProduct != null,
              onTap: () => _handlePurchase(
                context,
                premiumProvider,
                l10n,
                AppStrings.premiumLifetimeId,
              ),
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
  final bool isAvailable;
  final VoidCallback onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    required this.isPopular,
    this.savings,
    this.popularLabel,
    this.isLoading = false,
    this.isAvailable = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPopular
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: (isLoading || !isAvailable) ? null : onTap,
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.5,
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
                          if (!isAvailable) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(Coming Soon)',
                              style: TextStyle(
                                color: isDark ? Colors.grey[500] : Colors.grey[600],
                                fontSize: 11,
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
      ),
    );
  }
}
