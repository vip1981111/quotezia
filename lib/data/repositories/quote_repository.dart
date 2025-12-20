import 'package:hive/hive.dart';

import '../../core/constants/app_strings.dart';
import '../models/quote_model.dart';
import '../quotes/all_quotes.dart';

class QuoteRepository {
  late Box<Quote> _quotesBox;
  late Box<Quote> _favoritesBox;

  Future<void> init() async {
    _quotesBox = await Hive.openBox<Quote>(AppStrings.quotesBox);
    _favoritesBox = await Hive.openBox<Quote>(AppStrings.favoritesBox);

    // Load initial quotes if database is empty
    if (_quotesBox.isEmpty) {
      await _loadInitialQuotes();
    }
  }

  Future<void> _loadInitialQuotes() async {
    for (final quote in allQuotes) {
      await _quotesBox.put(quote.id, quote);
    }
  }

  Future<void> reloadQuotes() async {
    await _quotesBox.clear();
    await _loadInitialQuotes();
  }

  List<Quote> getAllQuotes() {
    return _quotesBox.values.toList();
  }

  List<Quote> getQuotesByCategory(String category) {
    return _quotesBox.values
        .where((quote) => quote.category == category)
        .toList();
  }

  List<Quote> getFavoriteQuotes() {
    return _favoritesBox.values.toList();
  }

  Future<void> addToFavorites(Quote quote) async {
    // Create separate copies for each box to avoid HiveError
    final favoriteQuote = quote.copyWith(isFavorite: true);
    final quotesBoxQuote = quote.copyWith(isFavorite: true);
    await _favoritesBox.put(quote.id, favoriteQuote);
    await _quotesBox.put(quote.id, quotesBoxQuote);
  }

  Future<void> removeFromFavorites(Quote quote) async {
    final quotesBoxQuote = quote.copyWith(isFavorite: false);
    await _favoritesBox.delete(quote.id);
    await _quotesBox.put(quote.id, quotesBoxQuote);
  }

  bool isFavorite(String quoteId) {
    return _favoritesBox.containsKey(quoteId);
  }

  Quote? getQuoteById(String id) {
    return _quotesBox.get(id);
  }

  Quote? getRandomQuote() {
    final quotes = getAllQuotes();
    if (quotes.isEmpty) return null;
    quotes.shuffle();
    return quotes.first;
  }

  Quote? getRandomQuoteByCategory(String category) {
    final quotes = getQuotesByCategory(category);
    if (quotes.isEmpty) return null;
    quotes.shuffle();
    return quotes.first;
  }

  Future<void> saveQuotes(List<Quote> quotes) async {
    for (final quote in quotes) {
      await _quotesBox.put(quote.id, quote);
    }
  }

  Future<void> clearAll() async {
    await _quotesBox.clear();
    await _favoritesBox.clear();
  }

  int get totalQuotes => _quotesBox.length;
  int get totalFavorites => _favoritesBox.length;

  int getQuoteCountByCategory(String category) {
    return getQuotesByCategory(category).length;
  }

  Map<String, int> getAllCategoryCounts() {
    final counts = <String, int>{};
    for (final category in [
      'motivation',
      'success',
      'wisdom',
      'life',
      'science',
      'love',
      'happiness',
      'friendship',
    ]) {
      counts[category] = getQuoteCountByCategory(category);
    }
    return counts;
  }
}
