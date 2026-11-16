import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/system_check/presentation/connection_check_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/connection-check',
    routes: [
      GoRoute(
        path: '/connection-check',
        builder: (context, state) => const ConnectionCheckScreen(),
      ),
      // PHASE 2: /login, /register, /home, /admin + redirect berbasis auth & role
    ],
  );
});
