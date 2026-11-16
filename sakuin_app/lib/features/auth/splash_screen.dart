import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core.dart';
import '../admin/pages/admin_shell.dart';
import '../home/home_shell.dart';
import '../setup/income_setup_screen.dart';
import 'onboarding_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    final repo = ref.read(repoProvider);

    // Menampilkan splash screen selama 900 milidetik
    await Future.delayed(const Duration(milliseconds: 900));

    Widget next = const OnboardingScreen();

    // Periksa apakah pengguna sudah memiliki token login
    if (await repo.hasToken()) {
      try {
        // Ambil informasi akun dari API Laravel
        final me = await repo.me();

        // Ambil role akun
        final role = me['role']?.toString().toLowerCase();

        if (role == 'admin') {
          // Admin diarahkan ke halaman Admin
          next = const AdminShell();
        } else if (role == 'user') {
          // Periksa pengaturan anggaran pengguna
          final bs = me['budget_setting'];

          final income = toNum(bs is Map ? bs['monthly_income'] : 0);

          if (income <= 0) {
            next = const IncomeSetupScreen();
          } else {
            next = const HomeShell();
          }
        } else {
          // Role tidak dikenali, arahkan ke halaman Welcome
          await repo.clearToken();
          next = const WelcomeScreen();
        }
      } catch (e) {
        // Jika token tidak valid atau sudah kedaluwarsa
        if (e is DioException && e.response?.statusCode == 401) {
          await repo.clearToken();
        }

        next = const WelcomeScreen();
      }
    }

    // Pastikan widget masih aktif sebelum navigasi
    if (!mounted) return;

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, SC.mint],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SakuinLogo(size: 48),
            SizedBox(height: 28),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: SC.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
