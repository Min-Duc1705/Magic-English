import 'achievement.dart';

class UserAchievement {
  final int id;
  final Achievement achievement;
  final DateTime? achievedAt;

  UserAchievement({
    required this.id,
    required this.achievement,
    this.achievedAt,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'] ?? 0,
      achievement: Achievement.fromJson(json['achievement'] ?? {}),
      achievedAt: json['achievedAt'] != null
          ? DateTime.parse(json['achievedAt'])
          : null,
    );
  }
}
