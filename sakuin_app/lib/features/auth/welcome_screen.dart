import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../admin/pages/admin_shell.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Widget _hero() {
    return SizedBox(
      width: 290,
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [SC.green, SC.greenDark],
              ),
              borderRadius: BorderRadius.circular(36),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x402E9E5B),
                  blurRadius: 30,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.white,
              size: 54,
            ),
          ),

          Positioned(
            top: 62,
            right: 76,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                size: 16,
                color: SC.green,
              ),
            ),
          ),

          const Positioned(
            top: 40,
            right: 0,
            child: FloatChip('AI aktif', icon: Icons.auto_awesome),
          ),

          const Positioned(bottom: 70, left: 0, child: FloatChip('50/30/20')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [SC.bg, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Column(
              children: [
                // Logo SAKUIN
                const Align(
                  alignment: Alignment.centerLeft,
                  child: SakuinLogo(),
                ),

                // Ilustrasi utama
                Expanded(child: Center(child: _hero())),

                const Text(
                  'SELAMAT DATANG DI SAKUIN',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w700,
                    color: SC.green,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Mulai kebiasaan finansial yang lebih sehat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Satu tempat untuk mengatur anggaran, '
                  'mencatat transaksi, dan merencanakan masa depan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: SC.mute, height: 1.5),
                ),

                const SizedBox(height: 24),

                // Tombol Masuk dan Daftar
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'Masuk',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: PrimaryButton(
                        label: 'Daftar',
                        outlined: true,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Pintasan Admin hanya untuk mode Debug
                if (kDebugMode)
                  TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminShell()),
                    ),
                    icon: const Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 14,
                      color: SC.green,
                    ),
                    label: const Text(
                      'Pratinjau Admin (debug)',
                      style: TextStyle(
                        color: SC.ink,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
