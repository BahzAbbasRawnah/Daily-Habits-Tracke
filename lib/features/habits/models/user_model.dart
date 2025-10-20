class User {
  final int? userID;
  final String name;
  final String? email;
  final String? password;
  final String language;
  final String theme;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.userID,
    required this.name,
    this.email,
    this.password,
    this.language = 'en',
    this.theme = 'light',
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userID: map['UserID'],
      name: map['Name'],
      email: map['Email'],
      password: map['Password'],
      language: map['Language'] ?? 'en',
      theme: map['Theme'] ?? 'light',
      createdAt: map['CreatedAt'] != null ? DateTime.parse(map['CreatedAt']) : null,
      updatedAt: map['UpdatedAt'] != null ? DateTime.parse(map['UpdatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'UserID': userID,
      'Name': name,
      'Email': email,
      'Password': password,
      'Language': language,
      'Theme': theme,
      'CreatedAt': createdAt?.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String(),
    };
  }
}