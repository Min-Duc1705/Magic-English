class Achievement {
  final int id;
  final String title;
  final String description;
  final String iconUrl;
  final int requiredValue;
  final String metricType;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.requiredValue,
    required this.metricType,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      requiredValue: json['requiredValue'] ?? 0,
      metricType: json['metricType'] ?? '',
    );
  }
}
