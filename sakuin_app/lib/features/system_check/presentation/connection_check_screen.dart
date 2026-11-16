import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import 'health_provider.dart';

class ConnectionCheckScreen extends ConsumerWidget {
  const ConnectionCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(healthStatusProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: health.when(
                loading: () => const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Menghubungi server...'),
                  ],
                ),
                error: (e, _) => _StatusCard(
                  icon: Icons.cloud_off_rounded,
                  color: AppColors.crimson,
                  title: 'Gagal terhubung',
                  subtitle: e.toString(),
                  onRetry: () => ref.invalidate(healthStatusProvider),
                ),
                data: (s) => _StatusCard(
                  icon: s.databaseOk
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  color: s.databaseOk ? AppColors.emerald : AppColors.amber,
                  title: 'Terhubung ke server',
                  subtitle:
                      '${s.app} • Database: ${s.databaseOk ? "OK" : "Bermasalah"}\n'
                      'Waktu server: ${DateFormat('dd MMM yyyy HH:mm').format(s.serverTime.toLocal())}\n'
                      'API: ${AppConfig.apiBaseUrl}',
                  onRetry: () => ref.invalidate(healthStatusProvider),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  const _StatusCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Cek ulang'),
            ),
          ],
        ),
      ),
    );
  }
}
