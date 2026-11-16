import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, required this.income});
  final bool income;
  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  static const _sources = [
    'Gaji',
    'Bonus',
    'Freelance',
    'Usaha',
    'Hadiah',
    'Lainnya',
  ];

  final _amount = TextEditingController();
  final _note = TextEditingController();
  String _source = 'Gaji';
  int? _categoryId;
  String? _bucket;
  DateTime _date = DateTime.now();
  bool _recurring = false;
  bool _loading = false;
  String? _error;

  num get _amt => num.tryParse(_amount.text) ?? 0;

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    if (_amt <= 0) {
      setState(() => _error = 'Masukkan nominal terlebih dahulu.');
      return;
    }
    if (!widget.income && _categoryId == null) {
      setState(() => _error = 'Pilih kategori pengeluaran.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final Json body = {
      'type': widget.income ? 'income' : 'expense',
      'amount': _amt,
      'transaction_date': _fmt(_date),
      'note': _note.text.trim().isEmpty ? null : _note.text.trim(),
      'is_recurring': _recurring,
    };
    if (widget.income) {
      body['source'] = _source;
    } else {
      body['category_id'] = _categoryId;
      body['bucket'] = _bucket;
    }
    try {
      await ref.read(repoProvider).addTransaction(body);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => _error = apiError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Text(
      t,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    ),
  );

  Widget _warning() {
    if (widget.income || _bucket == null || _amt <= 0)
      return const SizedBox.shrink();
    final dash = ref.watch(dashboardProvider).value;
    if (dash == null) return const SizedBox.shrink();
    final b = dash['month']['buckets'][_bucket];
    final remaining = toNum(b['remaining']);
    if (_amt <= remaining) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SC.redSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: SC.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pengeluaran ini melebihi batas ${bucketLabels[_bucket]} sebesar ${rupiah(_amt - remaining)}',
              style: const TextStyle(color: SC.red, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryGrid() {
    final cats = ref.watch(categoriesProvider('expense'));
    return cats.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(color: SC.green)),
      ),
      error: (e, _) => Text(apiError(e)),
      data: (items) => GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: .85,
        children: [
          for (final c in items)
            InkWell(
              onTap: () => setState(() {
                _categoryId = toNum(c['id']).toInt();
                _bucket = c['bucket'] as String?;
              }),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: _categoryId == toNum(c['id']).toInt()
                      ? SC.mint
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _categoryId == toNum(c['id']).toInt()
                        ? SC.green
                        : SC.line,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconForCategory(c['name'] as String?, false),
                      color: SC.green,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${c['name']}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final income = widget.income;
    return Scaffold(
      appBar: AppBar(
        title: Text(income ? 'Tambah Pemasukan' : 'Tambah Pengeluaran'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            const Text(
              'Nominal',
              style: TextStyle(
                fontSize: 12,
                color: SC.mute,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
              decoration: const InputDecoration(
                prefixText: 'Rp ',
                hintText: '0',
                border: InputBorder.none,
              ),
            ),
            Text(
              rupiah(_amt),
              style: const TextStyle(fontSize: 12, color: SC.mute),
            ),

            if (income) ...[
              _label('Sumber pemasukan'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in _sources)
                    ChoiceChip(
                      label: Text(s),
                      selected: _source == s,
                      selectedColor: SC.mint,
                      side: const BorderSide(color: SC.line),
                      onSelected: (_) => setState(() => _source = s),
                    ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SC.mint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: SC.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pemasukan ini akan dibagi otomatis ke 50/30/20.',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              _label('Kategori'),
              _categoryGrid(),
              _label('Bucket anggaran'),
              Wrap(
                spacing: 8,
                children: [
                  for (final e in bucketLabels.entries)
                    ChoiceChip(
                      label: Text(e.value),
                      selected: _bucket == e.key,
                      selectedColor: SC.mint,
                      side: const BorderSide(color: SC.line),
                      onSelected: (_) => setState(() => _bucket = e.key),
                    ),
                ],
              ),
              _warning(),
            ],

            _label('Tanggal'),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: cardDeco(radius: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: SC.mute,
                    ),
                    const SizedBox(width: 12),
                    Text(_fmt(_date)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SakuinField(
              label: 'Catatan (opsional)',
              controller: _note,
              icon: Icons.notes_outlined,
              hint: 'Mis. makan siang',
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: SC.green,
              title: Text(
                income
                    ? 'Pemasukan berulang (bulanan)'
                    : 'Pengeluaran berulang',
                style: const TextStyle(fontSize: 13),
              ),
              value: _recurring,
              onChanged: (v) => setState(() => _recurring = v),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: SC.red, fontSize: 12),
                ),
              ),
            PrimaryButton(
              label: income ? 'Simpan Pemasukan' : 'Simpan Pengeluaran',
              loading: _loading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
