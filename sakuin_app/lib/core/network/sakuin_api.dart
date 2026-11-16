import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import '../utils/format.dart';

typedef Json = Map<String, dynamic>;

// ==========================================
// TOKEN STORAGE
// ==========================================

class TokenStore {
  static const String _key = 'sakuin_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> read() {
    return _storage.read(key: _key);
  }

  Future<void> save(String token) {
    return _storage.write(key: _key, value: token);
  }

  Future<void> clear() {
    return _storage.delete(key: _key);
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) {
  return TokenStore();
});

// ==========================================
// DIO PROVIDER
// ==========================================

final sakuinDioProvider = Provider<Dio>((ref) {
  final store = ref.watch(tokenStoreProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await store.read();

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },
    ),
  );

  return dio;
});

// ==========================================
// API ERROR HANDLER
// ==========================================

String apiError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;

    if (data is Map) {
      final errors = data['errors'];

      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;

        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return 'Tidak dapat terhubung ke server. '
          'Pastikan server Laravel berjalan.';
    }

    if (error.type == DioExceptionType.receiveTimeout) {
      return 'Server terlalu lama merespons. Coba lagi.';
    }
  }

  return 'Terjadi kesalahan. Coba lagi.';
}

// ==========================================
// SAKUIN REPOSITORY
// ==========================================

class SakuinRepository {
  SakuinRepository(this._dio, this._tokens);

  final Dio _dio;
  final TokenStore _tokens;

  // ------------------------------------------
  // RESPONSE HELPERS
  // ------------------------------------------

  Json _map(dynamic data) {
    return Json.from(data as Map);
  }

  List<Json> _list(dynamic data) {
    return (data as List).map((item) => Json.from(item as Map)).toList();
  }

  // ------------------------------------------
  // AUTHENTICATION
  // ------------------------------------------

  Future<bool> hasToken() async {
    final token = await _tokens.read();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearToken() {
    return _tokens.clear();
  }

  Future<String> login(String email, String password) async {
    final response = await _dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );

    final data = _map(response.data);

    final token = data['token'];

    if (token is! String || token.isEmpty) {
      throw Exception('Token autentikasi tidak ditemukan.');
    }

    await _tokens.save(token);

    final user = data['user'];

    final role = data['role'] ?? (user is Map ? user['role'] : null) ?? 'user';

    return role.toString().toLowerCase();
  }

  Future<void> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String confirm,
  }) async {
    final response = await _dio.post(
      '/register',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': confirm,
      },
    );

    final data = _map(response.data);
    final token = data['token'];

    if (token is! String || token.isEmpty) {
      throw Exception('Token registrasi tidak ditemukan.');
    }

    await _tokens.save(token);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {
      // Token tetap dihapus meskipun server tidak merespons.
    }

    await _tokens.clear();
  }

  Future<Json> me() async {
    final response = await _dio.get('/me');
    return _map(response.data);
  }

  // ------------------------------------------
  // USER BUDGET
  // ------------------------------------------

  Future<bool> needsSetup() async {
    final user = await me();
    final budget = user['budget_setting'];

    final income = toNum(budget is Map ? budget['monthly_income'] : 0);

    return income <= 0;
  }

  Future<void> setupBudget(num income) async {
    await _dio.post('/budget/setup', data: {'monthly_income': income});
  }

  // ------------------------------------------
  // DASHBOARD
  // ------------------------------------------

  Future<Json> dashboard() async {
    final response = await _dio.get('/dashboard');
    return _map(response.data);
  }

  // ------------------------------------------
  // TRANSACTIONS
  // ------------------------------------------

  Future<List<Json>> transactions({String? type}) async {
    final response = await _dio.get(
      '/transactions',
      queryParameters: {if (type != null) 'type': type, 'per_page': 50},
    );

    return _list(response.data['data']);
  }

  Future<void> addTransaction(Json body) async {
    await _dio.post('/transactions', data: body);
  }

  Future<void> deleteTransaction(int id) async {
    await _dio.delete('/transactions/$id');
  }

  // ------------------------------------------
  // CATEGORIES
  // ------------------------------------------

  Future<List<Json>> categories(String type) async {
    final response = await _dio.get(
      '/categories',
      queryParameters: {'type': type},
    );

    return _list(response.data);
  }

  // ------------------------------------------
  // AI ASSISTANT
  // ------------------------------------------

  Future<Json> askAi(String question) async {
    final response = await _dio.post('/ai/ask', data: {'question': question});

    return _map(response.data);
  }

  Future<List<String>> aiPrompts() async {
    final response = await _dio.get('/ai/prompts');

    return (response.data as List).map((item) => item.toString()).toList();
  }

  // ------------------------------------------
  // NOTIFICATIONS
  // ------------------------------------------

  Future<List<Json>> notifications() async {
    final response = await _dio.get('/notifications');

    return _list(response.data['data']);
  }

  Future<void> markRead(int id) async {
    await _dio.post('/notifications/$id/read');
  }
}

// ==========================================
// REPOSITORY PROVIDER
// ==========================================

final repoProvider = Provider<SakuinRepository>((ref) {
  return SakuinRepository(
    ref.watch(sakuinDioProvider),
    ref.watch(tokenStoreProvider),
  );
});

// ==========================================
// RIVERPOD PROVIDERS
// ==========================================

final meProvider = FutureProvider.autoDispose<Json>((ref) {
  return ref.watch(repoProvider).me();
});

final dashboardProvider = FutureProvider.autoDispose<Json>((ref) {
  return ref.watch(repoProvider).dashboard();
});

final transactionsProvider = FutureProvider.autoDispose
    .family<List<Json>, String>((ref, type) {
      return ref
          .watch(repoProvider)
          .transactions(type: type.isEmpty ? null : type);
    });

final categoriesProvider = FutureProvider.autoDispose
    .family<List<Json>, String>((ref, type) {
      return ref.watch(repoProvider).categories(type);
    });

final aiPromptsProvider = FutureProvider.autoDispose<List<String>>((ref) {
  return ref.watch(repoProvider).aiPrompts();
});

final notificationsProvider = FutureProvider.autoDispose<List<Json>>((ref) {
  return ref.watch(repoProvider).notifications();
});
