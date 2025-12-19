import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_strings.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';
import '../../app/routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.settings,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.settings,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
              ),

              // Settings List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Appearance Section Title
                    _SectionTitle(title: l10n.appearance, isDark: isDark)
                        .animate()
                        .fadeIn(delay: 50.ms),

                    // Dark Mode
                    _SettingsCard(
                      title: l10n.darkMode,
                      icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      iconColor: Colors.amber,
                      trailing: Switch.adaptive(
                        value: themeProvider.isDarkMode,
                        onChanged: (_) => themeProvider.toggleTheme(),
                        activeTrackColor: primaryColor.withValues(alpha: 0.5),
                        activeThumbColor: primaryColor,
                      ),
                      onTap: () => themeProvider.toggleTheme(),
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),

                    const SizedBox(height: 12),

                    // Language
                    _SettingsCard(
                      title: l10n.language,
                      icon: Icons.language,
                      iconColor: Colors.blue,
                      subtitle: localeProvider.isArabic ? 'العربية' : 'English',
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showLanguageDialog(context, localeProvider),
                    ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1),

                    const SizedBox(height: 24),

                    // Notifications Section Title
                    _SectionTitle(title: l10n.notificationsSection, isDark: isDark)
                        .animate()
                        .fadeIn(delay: 200.ms),

                    // Enable Notifications
                    _SettingsCard(
                      title: l10n.enableNotifications,
                      icon: Icons.notifications_active,
                      iconColor: Colors.red,
                      trailing: Switch.adaptive(
                        value: settingsProvider.notificationsEnabled,
                        onChanged: (value) => settingsProvider.setNotificationsEnabled(value),
                        activeTrackColor: primaryColor.withValues(alpha: 0.5),
                        activeThumbColor: primaryColor,
                      ),
                      onTap: () => settingsProvider.toggleNotifications(),
                    ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.1),

                    const SizedBox(height: 12),

                    // Notification Time
                    _SettingsCard(
                      title: l10n.notificationTime,
                      subtitle: l10n.dailyReminder,
                      icon: Icons.access_time,
                      iconColor: Colors.indigo,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          settingsProvider.notificationTimeString,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      onTap: () => _showTimePicker(context, settingsProvider, l10n),
                    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

                    const SizedBox(height: 12),

                    // Test Notification Button
                    _SettingsCard(
                      title: 'Test Notification',
                      subtitle: 'Send a test notification now',
                      icon: Icons.notifications_none,
                      iconColor: Colors.deepOrange,
                      trailing: const Icon(Icons.send),
                      onTap: () => _sendTestNotification(context, localeProvider.isArabic),
                    ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.1),

                    const SizedBox(height: 24),

                    // Premium Section Title
                    _SectionTitle(title: l10n.premiumSection, isDark: isDark)
                        .animate()
                        .fadeIn(delay: 350.ms),

                    // Remove Ads
                    _SettingsCard(
                      title: l10n.removeAds,
                      subtitle: l10n.removeAdsDescription,
                      icon: Icons.workspace_premium,
                      iconColor: Colors.purple,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.deepPurple],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.premium),
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

                    const SizedBox(height: 24),

                    // App Section Title
                    _SectionTitle(title: l10n.appSection, isDark: isDark)
                        .animate()
                        .fadeIn(delay: 450.ms),

                    // Share App
                    _SettingsCard(
                      title: l10n.shareApp,
                      subtitle: l10n.shareAppDescription,
                      icon: Icons.share,
                      iconColor: Colors.teal,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _shareApp(),
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

                    const SizedBox(height: 12),

                    // Rate App
                    _SettingsCard(
                      title: l10n.rateApp,
                      icon: Icons.star_rate,
                      iconColor: Colors.orange,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _rateApp(),
                    ).animate().fadeIn(delay: 550.ms).slideX(begin: 0.1),

                    const SizedBox(height: 12),

                    // Contact Us
                    _SettingsCard(
                      title: l10n.contactUs,
                      subtitle: l10n.contactUsDescription,
                      icon: Icons.email,
                      iconColor: Colors.pink,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _contactUs(),
                    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),

                    const SizedBox(height: 24),

                    // Information Section Title
                    _SectionTitle(title: l10n.infoSection, isDark: isDark)
                        .animate()
                        .fadeIn(delay: 650.ms),

                    // Version
                    _SettingsCard(
                      title: l10n.version,
                      icon: Icons.info_outline,
                      iconColor: primaryColor,
                      trailing: Text(
                        '1.0.0',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {},
                    ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1),

                    const SizedBox(height: 12),

                    // Privacy Policy
                    _SettingsCard(
                      title: l10n.privacyPolicy,
                      icon: Icons.privacy_tip,
                      iconColor: Colors.green,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _launchUrl(AppStrings.privacyPolicyUrl),
                    ).animate().fadeIn(delay: 750.ms).slideX(begin: 0.1),

                    const SizedBox(height: 12),

                    // Terms of Service
                    _SettingsCard(
                      title: l10n.termsOfService,
                      icon: Icons.description,
                      iconColor: Colors.cyan,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _launchUrl(AppStrings.termsOfServiceUrl),
                    ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1),

                    const SizedBox(height: 32),

                    // App Info Footer
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Quotezia',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.madeWithLove,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey[600] : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 850.ms),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LocaleProvider localeProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.language,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            _LanguageOption(
              title: 'English',
              subtitle: 'English',
              isSelected: !localeProvider.isArabic,
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _LanguageOption(
              title: 'العربية',
              subtitle: 'Arabic',
              isSelected: localeProvider.isArabic,
              onTap: () {
                localeProvider.setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(
    BuildContext context,
    SettingsProvider settingsProvider,
    AppLocalizations l10n,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: settingsProvider.notificationTime,
      helpText: l10n.selectTime,
      cancelText: l10n.cancel,
      confirmText: l10n.ok,
    );

    if (picked != null) {
      await settingsProvider.setNotificationTime(picked);
    }
  }

  void _shareApp() {
    final String shareText = Platform.isIOS
        ? 'Check out Quotezia - Your Daily Inspiration!\n${AppStrings.appStoreUrl}'
        : 'Check out Quotezia - Your Daily Inspiration!\n${AppStrings.playStoreUrl}';

    Share.share(shareText);
  }

  void _rateApp() {
    final String storeUrl = Platform.isIOS
        ? AppStrings.appStoreUrl
        : AppStrings.playStoreUrl;

    _launchUrl(storeUrl);
  }

  void _contactUs() async {
    const email = 'vip1981.1@gmail.com';
    const subject = 'Quotezia Feedback';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=$subject',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _sendTestNotification(BuildContext context, bool isArabic) async {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    await notificationService.requestPermissions();
    await notificationService.showTestNotification(isArabic: isArabic);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'تم إرسال الإشعار!' : 'Notification sent!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.grey[800],
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Material(
      color: isSelected
          ? primaryColor.withValues(alpha: 0.15)
          : (isDark ? const Color(0xFF2D3748) : Colors.grey[100]),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? primaryColor : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? primaryColor
                            : (isDark ? Colors.white : Colors.grey[800]),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
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
