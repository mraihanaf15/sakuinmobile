enum UserStatus {
  active,
  suspended,
  pending,
}

class AdminUser {
  final String id;
  final String name;
  final String email;
  final UserStatus status;
  final String? phone;
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.phone,
    required this.createdAt,
  });

  AdminUser copyWith({
    String? id,
    String? name,
    String? email,
    UserStatus? status,
    String? phone,
    DateTime? createdAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: UserStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => UserStatus.pending,
      ),
      phone: json['phone']?.toString(),
      createdAt: DateTime.tryParse(
            json['created_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status.name,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
