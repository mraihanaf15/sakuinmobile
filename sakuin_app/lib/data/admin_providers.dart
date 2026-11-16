import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_mock_data.dart';
import 'admin_models.dart';

/// Penampung nilai sederhana (filter, pencarian, preferensi).
class ValueCubit<T> extends Notifier<T> {
  ValueCubit(this._initial);
  final T _initial;
  @override
  T build() => _initial;
  void set(T v) => state = v;
}

// ---------- Aktivitas ----------
final adminActivityProvider =
    NotifierProvider<AdminActivityNotifier, List<AdminActivity>>(
      AdminActivityNotifier.new,
    );

class AdminActivityNotifier extends Notifier<List<AdminActivity>> {
  int _seq = 1000;
  @override
  List<AdminActivity> build() => mockActivities();

  void add(ActivityType type, String description) {
    state = [
      AdminActivity(
        id: ++_seq,
        type: type,
        description: description,
        at: DateTime.now(),
        admin: 'Admin Sakuin',
      ),
      ...state,
    ];
  }
}

// ---------- Pengguna ----------
final adminUsersProvider =
    NotifierProvider<AdminUsersNotifier, List<AdminUser>>(
      AdminUsersNotifier.new,
    );

class AdminUsersNotifier extends Notifier<List<AdminUser>> {
  @override
  List<AdminUser> build() => mockUsers();

  void setStatus(int id, UserStatus s) {
    final u = state.firstWhere((e) => e.id == id);
    state = [for (final e in state) e.id == id ? e.copyWith(status: s) : e];
    ref
        .read(adminActivityProvider.notifier)
        .add(
          ActivityType.user,
          '${s == UserStatus.active ? 'Mengaktifkan' : 'Menonaktifkan'} akun ${u.name}',
        );
  }
}

final userSearchProvider = NotifierProvider<ValueCubit<String>, String>(
  () => ValueCubit<String>(''),
);
final userStatusFilterProvider =
    NotifierProvider<ValueCubit<UserStatus?>, UserStatus?>(
      () => ValueCubit<UserStatus?>(null),
    );

final filteredUsersProvider = Provider<List<AdminUser>>((ref) {
  final all = ref.watch(adminUsersProvider);
  final q = ref.watch(userSearchProvider).trim().toLowerCase();
  final st = ref.watch(userStatusFilterProvider);
  final list =
      all
          .where(
            (u) =>
                (st == null || u.status == st) &&
                (q.isEmpty ||
                    u.name.toLowerCase().contains(q) ||
                    u.email.toLowerCase().contains(q)),
          )
          .toList()
        ..sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
  return list;
});

// ---------- Kategori ----------
final adminCategoriesProvider =
    NotifierProvider<AdminCategoriesNotifier, List<AdminCategory>>(
      AdminCategoriesNotifier.new,
    );

class AdminCategoriesNotifier extends Notifier<List<AdminCategory>> {
  int _next = 100;
  @override
  List<AdminCategory> build() => mockCategories();

  void _log(String d) =>
      ref.read(adminActivityProvider.notifier).add(ActivityType.category, d);

  void add({
    required String name,
    required String icon,
    required CategoryType type,
    String? bucket,
    required bool active,
  }) {
    state = [
      ...state,
      AdminCategory(
        id: ++_next,
        name: name,
        icon: icon,
        type: type,
        bucket: bucket,
        active: active,
        usedCount: 0,
      ),
    ];
    _log('Kategori $name ditambahkan');
  }

  void update(
    int id, {
    required String name,
    required String icon,
    required CategoryType type,
    String? bucket,
    required bool active,
  }) {
    state = [
      for (final c in state)
        if (c.id == id)
          c.copyWith(
            name: name,
            icon: icon,
            type: type,
            bucket: bucket,
            clearBucket: bucket == null,
            active: active,
          )
        else
          c,
    ];
    _log('Kategori $name diperbarui');
  }

  void toggle(int id) {
    final c = state.firstWhere((e) => e.id == id);
    state = [
      for (final e in state) e.id == id ? e.copyWith(active: !e.active) : e,
    ];
    _log('Kategori ${c.name} ${c.active ? 'dinonaktifkan' : 'diaktifkan'}');
  }

  /// Hanya boleh dipanggil bila usedCount == 0 (diperiksa di UI).
  void remove(int id) {
    final c = state.firstWhere((e) => e.id == id);
    state = state.where((e) => e.id != id).toList();
    _log('Kategori ${c.name} dihapus');
  }
}

final categoryTypeFilterProvider =
    NotifierProvider<ValueCubit<CategoryType?>, CategoryType?>(
      () => ValueCubit<CategoryType?>(null),
    );

final filteredCategoriesProvider = Provider<List<AdminCategory>>((ref) {
  final all = ref.watch(adminCategoriesProvider);
  final t = ref.watch(categoryTypeFilterProvider);
  return all.where((c) => t == null || c.type == t).toList();
});

// ---------- Tips ----------
final adminTipsProvider = NotifierProvider<AdminTipsNotifier, List<AdminTip>>(
  AdminTipsNotifier.new,
);

class AdminTipsNotifier extends Notifier<List<AdminTip>> {
  int _next = 100;
  @override
  List<AdminTip> build() => mockTips();

  void _log(String d) =>
      ref.read(adminActivityProvider.notifier).add(ActivityType.tip, d);

  void add({
    required String title,
    required String body,
    required String category,
    required bool published,
  }) {
    state = [
      AdminTip(
        id: ++_next,
        title: title,
        body: body,
        category: category,
        published: published,
        updatedAt: DateTime.now(),
      ),
      ...state,
    ];
    _log(
      'Tips "$title" ${published ? 'dibuat dan dipublikasikan' : 'disimpan sebagai draf'}',
    );
  }

  void update(
    int id, {
    required String title,
    required String body,
    required String category,
    required bool published,
  }) {
    state = [
      for (final t in state)
        if (t.id == id)
          t.copyWith(
            title: title,
            body: body,
            category: category,
            published: published,
          )
        else
          t,
    ];
    _log('Tips "$title" diperbarui');
  }

  void setPublished(int id, bool v) {
    final t = state.firstWhere((e) => e.id == id);
    state = [for (final e in state) e.id == id ? e.copyWith(published: v) : e];
    _log(
      'Tips "${t.title}" ${v ? 'dipublikasikan' : 'ditarik dari publikasi'}',
    );
  }

  void remove(int id) {
    final t = state.firstWhere((e) => e.id == id);
    state = state.where((e) => e.id != id).toList();
    _log('Tips "${t.title}" dihapus');
  }
}

/// null = semua, true = terbit, false = draf
final tipStatusFilterProvider = NotifierProvider<ValueCubit<bool?>, bool?>(
  () => ValueCubit<bool?>(null),
);

final filteredTipsProvider = Provider<List<AdminTip>>((ref) {
  final all = ref.watch(adminTipsProvider);
  final f = ref.watch(tipStatusFilterProvider);
  return all.where((t) => f == null || t.published == f).toList();
});

// ---------- Aktivitas (filter) & Pengaturan ----------
final activityFilterProvider =
    NotifierProvider<ValueCubit<ActivityType?>, ActivityType?>(
      () => ValueCubit<ActivityType?>(null),
    );

final adminThemeModeProvider =
    NotifierProvider<ValueCubit<ThemeMode>, ThemeMode>(
      () => ValueCubit<ThemeMode>(ThemeMode.light),
    );

final adminNotifPrefsProvider =
    NotifierProvider<AdminNotifPrefs, Map<String, bool>>(AdminNotifPrefs.new);

class AdminNotifPrefs extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => {
    'new_user': true,
    'system': true,
    'weekly': false,
  };

  void toggle(String key) {
    final v = !(state[key] ?? false);
    state = {...state, key: v};
    ref
        .read(adminActivityProvider.notifier)
        .add(
          ActivityType.settings,
          'Pengaturan notifikasi "$key" ${v ? 'diaktifkan' : 'dimatikan'}',
        );
  }
}
