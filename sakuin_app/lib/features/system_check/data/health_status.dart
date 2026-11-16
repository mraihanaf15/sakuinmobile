class HealthStatus {
  final String app;
  final bool databaseOk;
  final DateTime serverTime;

  const HealthStatus({
    required this.app,
    required this.databaseOk,
    required this.serverTime,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) => HealthStatus(
    app: json['app'] as String,
    databaseOk: json['database'] as bool,
    serverTime: DateTime.parse(json['server_time'] as String),
  );
}
