import 'grammar_error.dart';

class Grammar {
  final int id;
  final String inputText;
  final String correctedText;
  final int score;
  final List<GrammarError> errors;
  final DateTime createdAt;

  Grammar({
    required this.id,
    required this.inputText,
    required this.correctedText,
    required this.score,
    required this.errors,
    required this.createdAt,
  });

  factory Grammar.fromJson(Map<String, dynamic> json) {
    return Grammar(
      id: json['id'] ?? 0,
      inputText: json['inputText'] ?? '',
      correctedText: json['correctedText'] ?? '',
      score: json['score'] ?? 0,
      errors:
          (json['errors'] as List<dynamic>?)
              ?.map((e) => GrammarError.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inputText': inputText,
      'correctedText': correctedText,
      'score': score,
      'errors': errors.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper method to get errors by type
  List<GrammarError> getErrorsByType(String type) {
    return errors
        .where((e) => e.errorType.toLowerCase() == type.toLowerCase())
        .toList();
  }

  // Get error count by type
  int getErrorCountByType(String type) {
    return errors
        .where((e) => e.errorType.toLowerCase() == type.toLowerCase())
        .length;
  }
}
