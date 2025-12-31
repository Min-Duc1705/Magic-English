class VocabularyBreakdown {
  final int verb;
  final int noun;
  final int adjective;
  final int adverb;
  final int other;

  VocabularyBreakdown({
    required this.verb,
    required this.noun,
    required this.adjective,
    required this.adverb,
    required this.other,
  });

  factory VocabularyBreakdown.fromJson(Map<String, int> json) {
    return VocabularyBreakdown(
      verb: json['verb'] ?? 0,
      noun: json['noun'] ?? 0,
      adjective: json['adjective'] ?? 0,
      adverb: json['adverb'] ?? 0,
      other: json['other'] ?? 0,
    );
  }

  int get total => verb + noun + adjective + adverb + other;

  double getPercentage(int value) {
    if (total == 0) return 0;
    return value / total;
  }
}

class CefrDistribution {
  final int a1;
  final int a2;
  final int b1;
  final int b2;
  final int c1;
  final int c2;

  CefrDistribution({
    required this.a1,
    required this.a2,
    required this.b1,
    required this.b2,
    required this.c1,
    required this.c2,
  });

  factory CefrDistribution.fromJson(Map<String, int> json) {
    return CefrDistribution(
      a1: json['A1'] ?? 0,
      a2: json['A2'] ?? 0,
      b1: json['B1'] ?? 0,
      b2: json['B2'] ?? 0,
      c1: json['C1'] ?? 0,
      c2: json['C2'] ?? 0,
    );
  }

  int get total => a1 + a2 + b1 + b2 + c1 + c2;

  int get maxValue {
    return [a1, a2, b1, b2, c1, c2].reduce((a, b) => a > b ? a : b);
  }

  double getNormalizedHeight(int value) {
    if (maxValue == 0) return 0;
    return value / maxValue;
  }
}
