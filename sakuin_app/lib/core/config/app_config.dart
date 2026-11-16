class AppConfig {
  AppConfig._();

  /// Emulator Android: 10.0.2.2 = localhost komputer.
  /// HP fisik: gunakan --dart-define=API_BASE_URL=http://IP_LAPTOP:8000/api
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );
}
