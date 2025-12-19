import 'package:flutter/material.dart';

import 'en.dart';
import 'ar.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': enStrings,
    'ar': arStrings,
  };

  String get appName => _localizedValues[locale.languageCode]!['appName']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get categories => _localizedValues[locale.languageCode]!['categories']!;
  String get favorites => _localizedValues[locale.languageCode]!['favorites']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get premium => _localizedValues[locale.languageCode]!['premium']!;
  String get share => _localizedValues[locale.languageCode]!['share']!;
  String get copy => _localizedValues[locale.languageCode]!['copy']!;
  String get addToFavorites => _localizedValues[locale.languageCode]!['addToFavorites']!;
  String get removeFromFavorites => _localizedValues[locale.languageCode]!['removeFromFavorites']!;
  String get darkMode => _localizedValues[locale.languageCode]!['darkMode']!;
  String get lightMode => _localizedValues[locale.languageCode]!['lightMode']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get rateApp => _localizedValues[locale.languageCode]!['rateApp']!;
  String get privacyPolicy => _localizedValues[locale.languageCode]!['privacyPolicy']!;
  String get termsOfService => _localizedValues[locale.languageCode]!['termsOfService']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get unlockPremium => _localizedValues[locale.languageCode]!['unlockPremium']!;
  String get noFavorites => _localizedValues[locale.languageCode]!['noFavorites']!;
  String get copiedToClipboard => _localizedValues[locale.languageCode]!['copiedToClipboard']!;
  String get quoteOfTheDay => _localizedValues[locale.languageCode]!['quoteOfTheDay']!;
  String get motivation => _localizedValues[locale.languageCode]!['motivation']!;
  String get love => _localizedValues[locale.languageCode]!['love']!;
  String get life => _localizedValues[locale.languageCode]!['life']!;
  String get wisdom => _localizedValues[locale.languageCode]!['wisdom']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get friendship => _localizedValues[locale.languageCode]!['friendship']!;
  String get faith => _localizedValues[locale.languageCode]!['faith']!;
  String get happiness => _localizedValues[locale.languageCode]!['happiness']!;
  String get restorePurchases => _localizedValues[locale.languageCode]!['restorePurchases']!;
  String get monthly => _localizedValues[locale.languageCode]!['monthly']!;
  String get yearly => _localizedValues[locale.languageCode]!['yearly']!;
  String get lifetime => _localizedValues[locale.languageCode]!['lifetime']!;
  String get adFreeExperience => _localizedValues[locale.languageCode]!['adFreeExperience']!;
  String get adFreeDescription => _localizedValues[locale.languageCode]!['adFreeDescription']!;
  String get unlimitedQuotes => _localizedValues[locale.languageCode]!['unlimitedQuotes']!;
  String get unlimitedQuotesDescription => _localizedValues[locale.languageCode]!['unlimitedQuotesDescription']!;
  String get customNotifications => _localizedValues[locale.languageCode]!['customNotifications']!;
  String get customNotificationsDescription => _localizedValues[locale.languageCode]!['customNotificationsDescription']!;
  String get exclusiveCategories => _localizedValues[locale.languageCode]!['exclusiveCategories']!;
  String get exclusiveCategoriesDescription => _localizedValues[locale.languageCode]!['exclusiveCategoriesDescription']!;
  String get perMonth => _localizedValues[locale.languageCode]!['perMonth']!;
  String get perYear => _localizedValues[locale.languageCode]!['perYear']!;
  String get oneTime => _localizedValues[locale.languageCode]!['oneTime']!;
  String get popular => _localizedValues[locale.languageCode]!['popular']!;
  String get save44 => _localizedValues[locale.languageCode]!['save44']!;
  String get next => _localizedValues[locale.languageCode]!['next']!;
  String get quotes => _localizedValues[locale.languageCode]!['quotes']!;
  String get deleteFromFavorites => _localizedValues[locale.languageCode]!['deleteFromFavorites']!;

  // New Settings translations
  String get appearance => _localizedValues[locale.languageCode]!['appearance']!;
  String get notificationsSection => _localizedValues[locale.languageCode]!['notificationsSection']!;
  String get enableNotifications => _localizedValues[locale.languageCode]!['enableNotifications']!;
  String get notificationTime => _localizedValues[locale.languageCode]!['notificationTime']!;
  String get dailyReminder => _localizedValues[locale.languageCode]!['dailyReminder']!;
  String get premiumSection => _localizedValues[locale.languageCode]!['premiumSection']!;
  String get removeAds => _localizedValues[locale.languageCode]!['removeAds']!;
  String get removeAdsDescription => _localizedValues[locale.languageCode]!['removeAdsDescription']!;
  String get appSection => _localizedValues[locale.languageCode]!['appSection']!;
  String get shareApp => _localizedValues[locale.languageCode]!['shareApp']!;
  String get shareAppDescription => _localizedValues[locale.languageCode]!['shareAppDescription']!;
  String get contactUs => _localizedValues[locale.languageCode]!['contactUs']!;
  String get contactUsDescription => _localizedValues[locale.languageCode]!['contactUsDescription']!;
  String get infoSection => _localizedValues[locale.languageCode]!['infoSection']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;
  String get madeWithLove => _localizedValues[locale.languageCode]!['madeWithLove']!;
  String get selectTime => _localizedValues[locale.languageCode]!['selectTime']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  String get deletedFromFavorites => _localizedValues[locale.languageCode]!['deletedFromFavorites']!;
  String get undo => _localizedValues[locale.languageCode]!['undo']!;
  String get swipeToDelete => _localizedValues[locale.languageCode]!['swipeToDelete']!;
  String get noFavoritesTitle => _localizedValues[locale.languageCode]!['noFavoritesTitle']!;
  String get noFavoritesSubtitle => _localizedValues[locale.languageCode]!['noFavoritesSubtitle']!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
