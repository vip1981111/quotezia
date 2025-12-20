import '../models/quote_model.dart';
import 'quotes_en.dart';
import 'quotes_ar.dart';

/// All quotes combined from English and Arabic sources
/// Total: 300 quotes (150 English + 150 Arabic)
final List<Quote> allQuotes = [...englishQuotes, ...arabicQuotes];

/// Get quotes by category
List<Quote> getQuotesByCategory(String category) {
  return allQuotes.where((quote) => quote.category == category).toList();
}

/// Get quote count by category
Map<String, int> getQuoteCountByCategory() {
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
    counts[category] = allQuotes.where((q) => q.category == category).length;
  }
  return counts;
}
