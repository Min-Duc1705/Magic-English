class ResponseRegister {
  final String name;
  final String email;

  ResponseRegister({required this.name, required this.email});

  factory ResponseRegister.fromJson(Map<String, dynamic> json) {
    return ResponseRegister(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email};
  }
}
