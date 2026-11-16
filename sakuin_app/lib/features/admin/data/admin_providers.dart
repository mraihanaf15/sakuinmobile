import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_models.dart';
import 'admin_mock_data.dart';

class AdminUsersNotifier extends StateNotifier<List<AdminUser>> {
  AdminUsersNotifier() : super(List.from(adminMockUsers));

  // Mengubah status akun pengguna.
  void setStatus(String userId, UserStatus newStatus) {
    state = [
      for (final user in state)
        if (user.id == userId)
          user.copyWith(status: newStatus)
        else
          user,
    ];
  }

  // Menambahkan pengguna.
  void addUser(AdminUser user) {
    state = [...state, user];
  }

  // Menghapus pengguna.
  void deleteUser(String userId) {
    state = state
        .where((user) => user.id != userId)
        .toList();
  }

  // Mencari pengguna berdasarkan nama atau email.
  List<AdminUser> searchUsers(String query) {
    final keyword = query.toLowerCase();

    return state.where((user) {
      return user.name.toLowerCase().contains(keyword) ||
          user.email.toLowerCase().contains(keyword);
    }).toList();
  }

  // Menghitung jumlah pengguna berdasarkan status.
  int countByStatus(UserStatus status) {
    return state.where((user) => user.status == status).length;
  }

  // Menghitung seluruh pengguna.
  int get totalUsers => state.length;
}

final adminUsersProvider =
    StateNotifierProvider<AdminUsersNotifier, List<AdminUser>>(
  (ref) => AdminUsersNotifier(),
);
