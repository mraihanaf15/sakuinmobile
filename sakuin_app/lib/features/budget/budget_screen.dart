import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: ref
          .watch(dashboardProvider)
          .when(
            loading: () =>
                const Center(child: CircularProgressIndicator(color: SC.green)),
            error: (e, _) => Center(child: Text(apiError(e))),
            data: (d) {
              final month = Json.from(d['month'] as Map);
              final buckets = Json.from(month['buckets'] as Map);
              const colors = <String, Color>{
                'needs': SC.green,
                'wants': SC.amber,
                'savings': SC.blue,
              };
              const statusText = {
                'aman': 'Aman',
                'hampir_habis': 'Hampir habis',
                'melebihi_batas': 'Melebihi batas',
              };
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  const Text(
                    'Anggaran 50/30/20',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dasar perhitungan: ${rupiah(toNum(month['base_income']))}',
                    style: const TextStyle(fontSize: 11, color: SC.mute),
                  ),
                  const SizedBox(height: 16),
                  for (final k in const ['needs', 'wants', 'savings'])
                    _card(
                      k,
                      Json.from(buckets[k] as Map),
                      colors[k]!,
                      statusText,
                    ),
                ],
              );
            },
          ),
    );
  }

  Widget _card(
    String key,
    Json b,
    Color color,
    Map<String, String> statusText,
  ) {
    final status = '${b['status']}';
    final double v = (toNum(b['used_percent']) / 100)
        .toDouble()
        .clamp(0.0, 1.0)
        .toDouble();
    final statusColor = status == 'melebihi_batas'
        ? SC.red
        : (status == 'hampir_habis' ? SC.amber : SC.green);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${bucketLabels[key]} (${b['percentage']}%)',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText[status] ?? status,
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 8,
              color: color,
              backgroundColor: SC.mint,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _kv('Batas', rupiah(toNum(b['limit']))),
              _kv('Terpakai', rupiah(toNum(b['used']))),
              _kv('Sisa', rupiah(toNum(b['remaining']))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(k, style: const TextStyle(fontSize: 10, color: SC.mute)),
      const SizedBox(height: 2),
      Text(
        v,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ],
  );
}
