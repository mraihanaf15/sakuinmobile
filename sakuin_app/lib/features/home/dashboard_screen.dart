import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core.dart';
import '../notifications/notifications_screen.dart';
import '../transactions/transactions_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, required this.onTab});
  final ValueChanged<int> onTab;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi,';
    if (h < 15) return 'Selamat siang,';
    if (h < 19) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dash = ref.watch(dashboardProvider);
    final name = ref.watch(meProvider).value?['name'] as String?;
    return SafeArea(
      child: RefreshIndicator(
        color: SC.green,
        onRefresh: () async {
          ref.invalidate(dashboardProvider);
          ref.invalidate(meProvider);
          await ref.read(dashboardProvider.future);
        },
        child: dash.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(color: SC.green)),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 80),
              Text(apiError(e), textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.invalidate(dashboardProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
          data: (d) => _content(context, ref, d, name),
        ),
      ),
    );
  }

  Widget _flow(String label, String value, IconData icon) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      const SizedBox(height: 4),
      Row(
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _legend(Color c, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  Widget _sectionHeader(String title, String action, VoidCallback onTap) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      GestureDetector(
        onTap: onTap,
        child: Text(
          action,
          style: const TextStyle(
            fontSize: 11,
            color: SC.green,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );

  Widget _content(BuildContext context, WidgetRef ref, Json d, String? name) {
    final month = Json.from(d['month'] as Map);
    final buckets = Json.from(month['buckets'] as Map);
    num limit = 0, used = 0;
    for (final b in buckets.values) {
      limit += toNum(b['limit']);
      used += toNum(b['used']);
    }
    final double pct = limit > 0 ? (used / limit * 100).toDouble() : 0.0;
    final recent = (d['recent_transactions'] as List)
        .map((e) => Json.from(e as Map))
        .toList();
    final unread = toNum(d['unread_notifications']).toInt();

    final ringColor = pct > 100 ? SC.red : (pct >= 80 ? SC.amber : SC.green);
    final subtitle = pct > 100
        ? 'Anggaranmu melebihi batas bulan ini'
        : (pct >= 80
              ? 'Anggaranmu hampir habis'
              : 'Pengeluaranmu masih terkendali');
    final insight = pct > 100
        ? 'Waspada! Pengeluaranmu sudah melewati batas anggaran bulan ini.'
        : (pct >= 80
              ? 'Hati-hati, anggaranmu hampir habis. Tahan dulu pengeluaran non-esensial.'
              : 'Bagus! Pengeluaranmu masih dalam batas anggaran bulan ini.');

    const colors = <String, Color>{
      'needs': SC.green,
      'wants': SC.amber,
      'savings': SC.blue,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(fontSize: 12, color: SC.mute),
                ),
                const SizedBox(height: 2),
                Text(
                  name ?? '...',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                );
                ref.invalidate(dashboardProvider);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: cardDeco(radius: 14),
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: SC.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Kartu saldo
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [SC.green, SC.greenDark],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Total saldo',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                rupiah(toNum(d['total_balance'])),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _flow(
                      'Pemasukan',
                      rupiah(toNum(month['income'])),
                      Icons.south_rounded,
                    ),
                  ),
                  Expanded(
                    child: _flow(
                      'Pengeluaran',
                      rupiah(toNum(month['expense'])),
                      Icons.north_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Anggaran
        _sectionHeader('Anggaran bulan ini', 'Lihat detail', () => onTab(2)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 11, color: SC.mute)),
        const SizedBox(height: 14),
        Row(
          children: [
            SizedBox(
              width: 104,
              height: 104,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(104, 104),
                    painter: RingPainter(
                      pct / 100,
                      color: ringColor,
                      stroke: 11,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${pct.round()}%',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        'terpakai',
                        style: TextStyle(fontSize: 9, color: SC.mute),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  for (final k in const ['needs', 'wants', 'savings'])
                    _legend(
                      colors[k]!,
                      bucketLabels[k]!,
                      '${toNum(buckets[k]['used_percent']).round()}%',
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SC.mint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: SC.green),
              const SizedBox(width: 10),
              Expanded(
                child: Text(insight, style: const TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Transaksi terbaru
        _sectionHeader('Transaksi terbaru', 'Lihat semua', () => onTab(1)),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text(
                'Belum ada transaksi, yuk catat yang pertama.',
                style: TextStyle(color: SC.mute, fontSize: 12),
              ),
            ),
          )
        else
          for (final t in recent) TransactionTile(t: t),
      ],
    );
  }
}
