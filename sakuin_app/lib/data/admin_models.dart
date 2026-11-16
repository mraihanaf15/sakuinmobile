enum UserStatus { active, suspended }

extension UserStatusX on UserStatus {
  String get label => this == UserStatus.active ? 'Aktif' : 'Nonaktif';
}

enum CategoryType { expense, income }

extension CategoryTypeX on CategoryType {
  String get label =>
      this == CategoryType.expense ? 'Pengeluaran' : 'Pemasukan';
}

enum ActivityType { login, logout, user, category, tip, settings }

extension ActivityTypeX on ActivityType {
  String get label => switch (this) {
    ActivityType.login => 'Login',
    ActivityType.logout => 'Logout',
    ActivityType.user => 'Pengguna',
    ActivityType.category => 'Kategori',
    ActivityType.tip => 'Tips',
    ActivityType.settings => 'Pengaturan',
  };
}

const adminBuckets = <String, String>{
  'needs': 'Kebutuhan',
  'wants': 'Keinginan',
  'savings': 'Tabungan',
};

const tipCategories = <String, String>{
  'umum': 'Umum',
  'anggaran': 'Anggaran',
  'menabung': 'Menabung',
  'pengeluaran': 'Pengeluaran',
  'darurat': 'Dana darurat',
  'gaya-hidup': 'Gaya hidup',
};

class AdminUser {
  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.joinedAt,
    required this.lastLoginAt,
    required this.status,
    required this.transactionsCount,
    required this.goalsCount,
    required this.aiQuestionsCount,
  });
  final int id;
  final String name, email, phone;
  final DateTime joinedAt;
  final DateTime? lastLoginAt;
  final UserStatus status;
  final int transactionsCount, goalsCount, aiQuestionsCount;

  AdminUser copyWith({UserStatus? status}) => AdminUser(
    id: id,
    name: name,
    email: email,
    phone: phone,
    joinedAt: joinedAt,
    lastLoginAt: lastLoginAt,
    status: status ?? this.status,
    transactionsCount: transactionsCount,
    goalsCount: goalsCount,
    aiQuestionsCount: aiQuestionsCount,
  );
}

class AdminCategory {
  const AdminCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.bucket,
    required this.active,
    required this.usedCount,
  });
  final int id;
  final String name, icon;
  final CategoryType type;
  final String? bucket;
  final bool active;
  final int usedCount;

  AdminCategory copyWith({
    String? name,
    String? icon,
    CategoryType? type,
    String? bucket,
    bool clearBucket = false,
    bool? active,
  }) => AdminCategory(
    id: id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    type: type ?? this.type,
    bucket: clearBucket ? null : (bucket ?? this.bucket),
    active: active ?? this.active,
    usedCount: usedCount,
  );
}

class AdminTip {
  const AdminTip({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.published,
    required this.updatedAt,
  });
  final int id;
  final String title, body, category;
  final bool published;
  final DateTime updatedAt;

  AdminTip copyWith({
    String? title,
    String? body,
    String? category,
    bool? published,
  }) => AdminTip(
    id: id,
    title: title ?? this.title,
    body: body ?? this.body,
    category: category ?? this.category,
    published: published ?? this.published,
    updatedAt: DateTime.now(),
  );
}

class AdminActivity {
  const AdminActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.at,
    required this.admin,
  });
  final int id;
  final ActivityType type;
  final String description, admin;
  final DateTime at;
}
