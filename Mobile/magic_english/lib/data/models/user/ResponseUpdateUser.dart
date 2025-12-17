class ResponseUpdateUser {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;

  ResponseUpdateUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  factory ResponseUpdateUser.fromJson(Map<String, dynamic> json) {
    return ResponseUpdateUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'avatarUrl': avatarUrl};
  }
}
