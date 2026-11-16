import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/health_repository.dart';
import '../data/health_status.dart';

final healthStatusProvider = FutureProvider.autoDispose<HealthStatus>(
  (ref) => ref.watch(healthRepositoryProvider).check(),
);
