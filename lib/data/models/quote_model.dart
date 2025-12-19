import 'package:hive/hive.dart';

part 'quote_model.g.dart';

@HiveType(typeId: 0)
class Quote extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String textAr;

  @HiveField(3)
  final String author;

  @HiveField(4)
  final String authorAr;

  @HiveField(5)
  final String category;

  @HiveField(6)
  bool isFavorite;

  @HiveField(7)
  final bool isPremium;

  Quote({
    required this.id,
    required this.text,
    required this.textAr,
    required this.author,
    required this.authorAr,
    required this.category,
    this.isFavorite = false,
    this.isPremium = false,
  });

  Quote copyWith({
    String? id,
    String? text,
    String? textAr,
    String? author,
    String? authorAr,
    String? category,
    bool? isFavorite,
    bool? isPremium,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      textAr: textAr ?? this.textAr,
      author: author ?? this.author,
      authorAr: authorAr ?? this.authorAr,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'textAr': textAr,
      'author': author,
      'authorAr': authorAr,
      'category': category,
      'isFavorite': isFavorite,
      'isPremium': isPremium,
    };
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      text: json['text'] as String,
      textAr: json['textAr'] as String,
      author: json['author'] as String,
      authorAr: json['authorAr'] as String,
      category: json['category'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'Quote(id: $id, text: $text, author: $author, category: $category)';
  }
}

enum QuoteCategory {
  motivation,
  love,
  life,
  wisdom,
  success,
  friendship,
  faith,
  happiness,
}

extension QuoteCategoryExtension on QuoteCategory {
  String get value {
    switch (this) {
      case QuoteCategory.motivation:
        return 'motivation';
      case QuoteCategory.love:
        return 'love';
      case QuoteCategory.life:
        return 'life';
      case QuoteCategory.wisdom:
        return 'wisdom';
      case QuoteCategory.success:
        return 'success';
      case QuoteCategory.friendship:
        return 'friendship';
      case QuoteCategory.faith:
        return 'faith';
      case QuoteCategory.happiness:
        return 'happiness';
    }
  }
}
