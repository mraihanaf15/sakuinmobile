import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core.dart';
import '../home/home_shell.dart';

class IncomeSetupScreen extends ConsumerStatefulWidget {
  const IncomeSetupScreen({super.key});
  @override
  ConsumerState<IncomeSetupScreen> createState() => _IncomeSetupScreenState();
}

class _IncomeSetupScreenState extends ConsumerState<IncomeSetupScreen> {
  final _c = TextEditingController();
  bool _loading = false;
  String? _error;

  num get _value => num.tryParse(_c.text) ?? 0;

  Future<void> _save() async {
    if (_value <= 0) {
      setState(() => _error = 'Masukkan penghasilan bulanan terlebih dahulu.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(repoProvider).setupBudget(_value);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (r) => false,
      );
    } catch (e) {
      if (mounted) setState(() => _error = apiError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _split(String label, int pct, Color color) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: cardDeco(radius: 16),
    child: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label ($pct%)',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          rupiah(_value * pct / 100),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atur penghasilan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Masukkan penghasilan bulanan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Sakuin membaginya otomatis dengan metode 50/30/20.',
              style: TextStyle(fontSize: 12, color: SC.mute),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _c,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                hintText: '0',
                border: InputBorder.none,
              ),
            ),
            Text(
              rupiah(_value),
              style: const TextStyle(color: SC.mute, fontSize: 12),
            ),
            const Divider(height: 32, color: SC.line),
            _split('Kebutuhan', 50, SC.green),
            _split('Keinginan', 30, SC.amber),
            _split('Tabungan & Investasi', 20, SC.blue),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: SC.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Hitung 50/30/20 & Mulai',
              loading: _loading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
