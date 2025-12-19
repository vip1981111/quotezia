import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'data/models/quote_model.dart';
import 'data/repositories/quote_repository.dart';
import 'providers/quote_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/premium_provider.dart';
import 'services/storage_service.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'services/premium_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(QuoteAdapter());

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  // Initialize repository
  final quoteRepository = QuoteRepository();
  await quoteRepository.init();

  // Initialize Ad Service
  final adService = AdService();
  await adService.initialize();

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize Premium Service
  final premiumService = PremiumService();
  await premiumService.initialize(storageService);

  // Run app with providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storageService)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(storageService)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => QuoteProvider(quoteRepository)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(storageService)..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => PremiumProvider(premiumService),
        ),
        Provider<AdService>.value(value: adService),
        Provider<NotificationService>.value(value: notificationService),
      ],
      child: const QuoteziaApp(),
    ),
  );
}
