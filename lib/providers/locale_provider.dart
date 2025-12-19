import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../core/constants/app_strings.dart';

class LocaleProvider extends ChangeNotifier {
  final StorageService _storageService;
  Locale _locale = const Locale('en');

  LocaleProvider(this._storageService);

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> init() async {
    final savedLocale = _storageService.getString(AppStrings.localeKey);
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'ar'].contains(locale.languageCode)) return;

    _locale = locale;
    await _storageService.setString(AppStrings.localeKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    if (_locale.languageCode == 'en') {
      await setLocale(const Locale('ar'));
    } else {
      await setLocale(const Locale('en'));
    }
  }
}
