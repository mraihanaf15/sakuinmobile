import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.t, this.onLongPress});
  final Json t;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final income = t['type'] == 'income';
    final catName = t['category'] is Map
        ? t['category']['name'] as String?
        : null;
    final label =
        catName ??
        (t['source'] as String?) ??
        (income ? 'Pemasukan' : 'Lainnya');
    final note = t['note'] as String?;
    final title = (note != null && note.isNotEmpty) ? note : label;
    final amount = toNum(t['amount']);

    return InkWell(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: SC.mint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                iconForCategory(catName, income),
                color: SC.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$label · ${dateLabel('${t['transaction_date']}')}',
                    style: const TextStyle(fontSize: 10, color: SC.mute),
                  ),
                ],
              ),
            ),
            Text(
              '${income ? '+' : '-'}${rupiah(amount)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: income ? SC.green : SC.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});
  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _type = ''; // '' = semua

  Future<void> _confirmDelete(Json t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: const Text('Transaksi ini akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: SC.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(repoProvider).deleteTransaction(toNum(t['id']).toInt());
      ref.invalidate(transactionsProvider);
      ref.invalidate(dashboardProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiError(e))));
      }
    }
  }

  Widget _chip(String label, String value) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _type == value,
      selectedColor: SC.mint,
      labelStyle: TextStyle(
        fontSize: 12,
        color: _type == value ? SC.greenDark : SC.mute,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: SC.line),
      onSelected: (_) => setState(() => _type = value),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(transactionsProvider(_type));
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat transaksi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tekan lama pada transaksi untuk menghapus.',
              style: TextStyle(fontSize: 11, color: SC.mute),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _chip('Semua', ''),
                _chip('Pemasukan', 'income'),
                _chip('Pengeluaran', 'expense'),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                color: SC.green,
                onRefresh: () async {
                  ref.invalidate(transactionsProvider);
                  await ref.read(transactionsProvider(_type).future);
                },
                child: list.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: SC.green),
                  ),
                  error: (e, _) => ListView(
                    children: [
                      const SizedBox(height: 60),
                      Center(child: Text(apiError(e))),
                    ],
                  ),
                  data: (items) => items.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 80),
                            Center(
                              child: Text(
                                'Belum ada transaksi.',
                                style: TextStyle(color: SC.mute),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: SC.line),
                          itemBuilder: (_, i) => TransactionTile(
                            t: items[i],
                            onLongPress: () => _confirmDelete(items[i]),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
