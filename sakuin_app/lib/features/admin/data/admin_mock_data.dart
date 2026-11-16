import 'admin_models.dart';

final List<AdminUser> adminMockUsers = [
  AdminUser(
    id: 'USR001',
    name: 'Ahmad Fauzi',
    email: 'ahmad@example.com',
    status: UserStatus.active,
    phone: '081234567890',
    createdAt: DateTime(2026, 1, 10),
  ),
  AdminUser(
    id: 'USR002',
    name: 'Siti Rahma',
    email: 'siti@example.com',
    status: UserStatus.active,
    phone: '081234567891',
    createdAt: DateTime(2026, 2, 15),
  ),
  AdminUser(
    id: 'USR003',
    name: 'Budi Santoso',
    email: 'budi@example.com',
    status: UserStatus.suspended,
    phone: '081234567892',
    createdAt: DateTime(2026, 3, 20),
  ),
  AdminUser(
    id: 'USR004',
    name: 'Dewi Lestari',
    email: 'dewi@example.com',
    status: UserStatus.pending,
    phone: '081234567893',
    createdAt: DateTime(2026, 4, 5),
  ),
  AdminUser(
    id: 'USR005',
    name: 'Rizky Pratama',
    email: 'rizky@example.com',
    status: UserStatus.active,
    phone: '081234567894',
    createdAt: DateTime(2026, 5, 12),
  ),
];
