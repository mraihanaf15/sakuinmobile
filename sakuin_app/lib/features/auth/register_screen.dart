import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core.dart';
import '../setup/income_setup_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _agree = false;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _pass.text.isEmpty) {
      setState(() => _error = 'Nama, email, dan kata sandi wajib diisi.');
      return;
    }
    if (_pass.text != _confirm.text) {
      setState(() => _error = 'Konfirmasi kata sandi tidak sama.');
      return;
    }
    if (!_agree) {
      setState(() => _error = 'Setujui syarat & ketentuan terlebih dahulu.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(repoProvider)
          .register(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            password: _pass.text,
            confirm: _confirm.text,
          );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const IncomeSetupScreen()),
        (r) => false,
      );
    } catch (e) {
      if (mounted) setState(() => _error = apiError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const SakuinLogo(size: 24), centerTitle: true),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const Text(
              'Buat akun Sakuin',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            const Text(
              'Mulai atur keuanganmu dengan metode 50/30/20.',
              style: TextStyle(fontSize: 12, color: SC.mute),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SC.redSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: SC.red, fontSize: 12),
                ),
              ),
            SakuinField(
              label: 'Nama lengkap',
              controller: _name,
              icon: Icons.person_outline,
              hint: 'Nama kamu',
            ),
            const SizedBox(height: 14),
            SakuinField(
              label: 'Email',
              controller: _email,
              icon: Icons.mail_outline,
              hint: 'nama@email.com',
              keyboard: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            SakuinField(
              label: 'Nomor HP (opsional)',
              controller: _phone,
              icon: Icons.phone_outlined,
              hint: '08xxxxxxxxxx',
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            SakuinField(
              label: 'Kata sandi (min. 8 karakter)',
              controller: _pass,
              icon: Icons.lock_outline,
              obscure: true,
            ),
            const SizedBox(height: 14),
            SakuinField(
              label: 'Konfirmasi kata sandi',
              controller: _confirm,
              icon: Icons.lock_outline,
              obscure: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _agree,
                  activeColor: SC.green,
                  onChanged: (v) => setState(() => _agree = v ?? false),
                ),
                const Expanded(
                  child: Text(
                    'Saya setuju dengan syarat & ketentuan Sakuin',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Daftar',
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sudah punya akun? ',
                  style: TextStyle(fontSize: 12, color: SC.mute),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 12,
                      color: SC.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
