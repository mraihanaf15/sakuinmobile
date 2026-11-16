import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakuin/features/system_check/data/health_status.dart';
import 'package:sakuin/features/system_check/presentation/health_provider.dart';
import 'package:sakuin/main.dart';

void main() {
  testWidgets('menampilkan status server saat API sukses', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          healthStatusProvider.overrideWith(
            (ref) => Future.value(HealthStatus(
              app: 'SAKUIN',
              databaseOk: true,
              serverTime: DateTime(2026, 1, 1),
            )),
          ),
        ],
        child: const SakuinApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Terhubung ke server'), findsOneWidget);
  });
}