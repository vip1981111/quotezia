import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/localization/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import 'routes.dart';
import 'theme.dart';

class QuoteziaApp extends StatelessWidget {
  const QuoteziaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp(
          title: 'Quotezia',
          debugShowCheckedModeBanner: false,

          // Theme with animation
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          themeAnimationDuration: const Duration(milliseconds: 300),
          themeAnimationCurve: Curves.easeInOut,

          // Localization
          locale: localeProvider.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Routes
          initialRoute: AppRoutes.main,
          onGenerateRoute: AppRoutes.generateRoute,

          // Builder for global settings
          builder: (context, child) {
            return Directionality(
              textDirection: localeProvider.isArabic
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
