class Vocabulary {
  final int? id;
  final String word;
  final String ipa;
  final String audioUrl;
  final String meaning;
  final String wordType;
  final String example;
  final String cefrLevel;
  final DateTime createdAt;

  Vocabulary({
    this.id,
    required this.word,
    required this.ipa,
    required this.audioUrl,
    required this.meaning,
    required this.wordType,
    required this.example,
    required this.cefrLevel,
    required this.createdAt,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    // Handle examples array from backend (join into single string)
    String exampleText = '';
    if (json['examples'] != null) {
      if (json['examples'] is List) {
        exampleText = (json['examples'] as List).join('\n');
      } else {
        exampleText = json['examples'].toString();
      }
    }

    return Vocabulary(
      id: json['id'],
      word: json['word'] ?? '',
      ipa: json['ipa'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      meaning: json['meaning'] ?? '',
      wordType: json['wordType'] ?? '',
      example: exampleText,
      cefrLevel: json['cefrLevel'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'ipa': ipa,
      'audioUrl': audioUrl,
      'meaning': meaning,
      'wordType': wordType,
      'example': example,
      'cefrLevel': cefrLevel,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
