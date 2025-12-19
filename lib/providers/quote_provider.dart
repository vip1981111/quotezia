import 'package:flutter/foundation.dart';

import '../data/models/quote_model.dart';
import '../data/repositories/quote_repository.dart';

class QuoteProvider extends ChangeNotifier {
  final QuoteRepository _repository;

  List<Quote> _quotes = [];
  List<Quote> _favorites = [];
  List<Quote> _categoryQuotes = [];
  Quote? _currentQuote;
  Quote? _quoteOfTheDay;
  String _selectedCategory = '';
  bool _isLoading = false;
  String? _error;
  Map<String, int> _categoryCounts = {};

  QuoteProvider(this._repository);

  // Getters
  List<Quote> get quotes => _quotes;
  List<Quote> get favorites => _favorites;
  List<Quote> get categoryQuotes => _categoryQuotes;
  Quote? get currentQuote => _currentQuote;
  Quote? get quoteOfTheDay => _quoteOfTheDay;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalQuotes => _repository.totalQuotes;
  int get totalFavorites => _repository.totalFavorites;
  Map<String, int> get categoryCounts => _categoryCounts;

  Future<void> init() async {
    _setLoading(true);
    try {
      await _repository.init();
      await loadAllQuotes();
      await loadFavorites();
      await loadQuoteOfTheDay();
      loadCategoryCounts();
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> loadAllQuotes() async {
    _quotes = _repository.getAllQuotes();
    notifyListeners();
  }

  Future<void> loadQuotesByCategory(String category) async {
    _setLoading(true);
    _selectedCategory = category;
    _categoryQuotes = _repository.getQuotesByCategory(category);
    _setLoading(false);
  }

  Future<void> loadFavorites() async {
    _favorites = _repository.getFavoriteQuotes();
    notifyListeners();
  }

  Future<void> loadQuoteOfTheDay() async {
    _quoteOfTheDay = _repository.getRandomQuote();
    notifyListeners();
  }

  void loadNextQuote() {
    _quoteOfTheDay = _repository.getRandomQuote();
    notifyListeners();
  }

  Future<void> toggleFavorite(Quote quote) async {
    if (_repository.isFavorite(quote.id)) {
      await _repository.removeFromFavorites(quote);
    } else {
      await _repository.addToFavorites(quote);
    }
    await loadFavorites();
    await loadAllQuotes();

    // Update quoteOfTheDay if it's the same quote
    if (_quoteOfTheDay != null && _quoteOfTheDay!.id == quote.id) {
      _quoteOfTheDay = _repository.getQuoteById(quote.id);
    }

    // Update category quotes if viewing a category
    if (_selectedCategory.isNotEmpty) {
      _categoryQuotes = _repository.getQuotesByCategory(_selectedCategory);
    }
    notifyListeners();
  }

  bool isFavorite(String quoteId) {
    return _repository.isFavorite(quoteId);
  }

  void setCurrentQuote(Quote quote) {
    _currentQuote = quote;
    notifyListeners();
  }

  Quote? getRandomQuote() {
    return _repository.getRandomQuote();
  }

  Quote? getRandomQuoteByCategory(String category) {
    return _repository.getRandomQuoteByCategory(category);
  }

  void loadCategoryCounts() {
    _categoryCounts = _repository.getAllCategoryCounts();
    notifyListeners();
  }

  int getQuoteCountForCategory(String category) {
    return _categoryCounts[category] ?? 0;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
