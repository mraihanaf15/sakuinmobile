import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core.dart';
import '../auth/welcome_screen.dart';
import '../notifications/notifications_screen.dart';
import '../setup/income_setup_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Widget _tile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: SC.mint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color ?? SC.green, size: 20),
    ),
    title: Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color ?? SC.ink,
      ),
    ),
    trailing: const Icon(Icons.chevron_right_rounded, color: SC.mute),
    onTap: onTap,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider).value;
    final name = (me?['name'] as String?) ?? '...';
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Profil',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: SC.mint,
                child: Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    color: SC.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${me?['email'] ?? ''}',
                      style: const TextStyle(fontSize: 12, color: SC.mute),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: SC.line),
          _tile(Icons.payments_outlined, 'Ubah penghasilan bulanan', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IncomeSetupScreen()),
            );
          }),
          _tile(Icons.notifications_none_rounded, 'Notifikasi', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          }),
          _tile(Icons.logout_rounded, 'Keluar', () async {
            await ref.read(repoProvider).logout();
            if (!context.mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (r) => false,
            );
          }, color: SC.red),
        ],
      ),
    );
  }
}
