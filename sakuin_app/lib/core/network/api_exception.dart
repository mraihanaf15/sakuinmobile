import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException('Koneksi ke server timeout. Coba lagi.');
      case DioExceptionType.connectionError:
        return const ApiException(
          'Tidak dapat terhubung ke server. Periksa jaringan dan alamat API.',
        );
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        final msg = (data is Map && data['message'] is String)
            ? data['message'] as String
            : 'Terjadi kesalahan pada server.';
        return ApiException(msg, statusCode: e.response?.statusCode);
      default:
        return const ApiException('Terjadi kesalahan tak terduga.');
    }
  }

  @override
  String toString() => message;
}
