/// Datos editables del perfil. No incluye contrasena (ver README: autenticacion local).
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.avatar,
    required this.income,
    required this.budget,
  });

  final String name;
  final String email;
  final String avatar;
  final int income;
  final int budget;

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatar,
    int? income,
    int? budget,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      income: income ?? this.income,
      budget: budget ?? this.budget,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'avatar': avatar,
        'income': income,
        'budget': budget,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String,
      income: (json['income'] as num).toInt(),
      budget: (json['budget'] as num).toInt(),
    );
  }
}
