class GrammarError {
  final int id;
  final String errorType;
  final String beforeText;
  final String errorText;
  final String correctedText;
  final String afterText;
  final String explanation;
  final int? startPosition;
  final int? endPosition;

  GrammarError({
    required this.id,
    required this.errorType,
    required this.beforeText,
    required this.errorText,
    required this.correctedText,
    required this.afterText,
    required this.explanation,
    this.startPosition,
    this.endPosition,
  });

  factory GrammarError.fromJson(Map<String, dynamic> json) {
    return GrammarError(
      id: json['id'] ?? 0,
      errorType: json['errorType'] ?? 'grammar',
      beforeText: json['beforeText'] ?? '',
      errorText: json['errorText'] ?? '',
      correctedText: json['correctedText'] ?? '',
      afterText: json['afterText'] ?? '',
      explanation: json['explanation'] ?? '',
      startPosition: json['startPosition'],
      endPosition: json['endPosition'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'errorType': errorType,
      'beforeText': beforeText,
      'errorText': errorText,
      'correctedText': correctedText,
      'afterText': afterText,
      'explanation': explanation,
      'startPosition': startPosition,
      'endPosition': endPosition,
    };
  }
}
