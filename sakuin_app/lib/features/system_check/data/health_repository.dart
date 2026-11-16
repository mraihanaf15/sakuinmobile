import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'health_status.dart';

class HealthRepository {
  final Dio _dio;
  HealthRepository(this._dio);

  Future<HealthStatus> check() async {
    try {
      final res = await _dio.get('/health');
      return HealthStatus.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      // Saat database mati, server membalas 503 tetapi body tetap berisi data status.
      final data = e.response?.data;
      if (e.response?.statusCode == 503 &&
          data is Map &&
          data['data'] is Map<String, dynamic>) {
        return HealthStatus.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw ApiException.fromDio(e);
    }
  }
}

final healthRepositoryProvider = Provider<HealthRepository>(
  (ref) => HealthRepository(ref.watch(dioProvider)),
);
