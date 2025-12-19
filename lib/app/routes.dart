import 'package:flutter/material.dart';

import '../features/main/main_screen.dart';
import '../features/home/home_screen.dart';
import '../features/categories/categories_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/premium/premium_screen.dart';
import '../features/category_quotes/category_quotes_screen.dart';

class AppRoutes {
  static const String main = '/';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String categoryQuotes = '/category-quotes';
  static const String favorites = '/favorites';
  static const String settings = '/settings';
  static const String premium = '/premium';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());
      case categoryQuotes:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CategoryQuotesScreen(
            categoryName: args['categoryName'] as String,
            categoryValue: args['categoryValue'] as String,
            categoryColor: args['categoryColor'] as Color,
            categoryIcon: args['categoryIcon'] as IconData,
          ),
        );
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case premium:
        return MaterialPageRoute(builder: (_) => const PremiumScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
