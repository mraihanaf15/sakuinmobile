import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core.dart';

class _Msg {
  _Msg(this.text, this.mine, [this.health]);
  final String text;
  final bool mine;
  final Json? health;
}

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});
  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  final _c = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _msgs = [
    _Msg(
      'Halo! Aku asisten keuangan Sakuin. Tanyakan apa saja soal keuanganmu bulan ini.',
      false,
    ),
  ];
  bool _loading = false;

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String q) async {
    q = q.trim();
    if (q.isEmpty || _loading) return;
    setState(() {
      _msgs.add(_Msg(q, true));
      _loading = true;
      _c.clear();
    });
    _toBottom();
    try {
      final r = await ref.read(repoProvider).askAi(q);
      _msgs.add(
        _Msg(
          r['answer'] as String,
          false,
          r['health'] is Map ? Json.from(r['health'] as Map) : null,
        ),
      );
    } catch (e) {
      _msgs.add(_Msg(apiError(e), false));
    }
    if (!mounted) return;
    setState(() => _loading = false);
    _toBottom();
  }

  @override
  Widget build(BuildContext context) {
    final prompts = ref.watch(aiPromptsProvider).value ?? const <String>[];
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: SC.mint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: SC.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanya AI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Cek kesehatan keuanganmu',
                      style: TextStyle(fontSize: 11, color: SC.mute),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: SC.line),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _msgs.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _msgs.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SC.green,
                        ),
                      ),
                    ),
                  );
                }
                final m = _msgs[i];
                return Column(
                  crossAxisAlignment: m.mine
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(
                        color: m.mine ? SC.green : SC.bg,
                        borderRadius: BorderRadius.circular(16),
                        border: m.mine ? null : Border.all(color: SC.line),
                      ),
                      child: Text(
                        m.text,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: m.mine ? Colors.white : SC.ink,
                        ),
                      ),
                    ),
                    if (m.health != null) _HealthCard(m.health!),
                  ],
                );
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final p in prompts)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(p, style: const TextStyle(fontSize: 11)),
                      backgroundColor: SC.mint,
                      side: BorderSide.none,
                      onPressed: () => _send(p),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _c,
                    onSubmitted: _send,
                    decoration: InputDecoration(
                      hintText: 'Tulis pertanyaanmu...',
                      hintStyle: const TextStyle(fontSize: 13, color: SC.mute),
                      filled: true,
                      fillColor: SC.bg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: SC.line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: SC.line),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: SC.green),
                  onPressed: () => _send(_c.text),
                  icon: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard(this.h);
  final Json h;

  @override
  Widget build(BuildContext context) {
    const labels = {'sehat': 'Sehat', 'waspada': 'Waspada', 'kritis': 'Kritis'};
    const colors = <String, Color>{
      'sehat': SC.green,
      'waspada': SC.amber,
      'kritis': SC.red,
    };
    final status = '${h['status']}';
    final color = colors[status] ?? SC.mute;
    final score = toNum(h['score']).toDouble();
    final actual = h['actual'] is Map ? h['actual'] as Map : const {};

    Widget row(String l, String key, String rule) => Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(child: Text(l, style: const TextStyle(fontSize: 11))),
          Text(
            '${toNum(actual[key])}% ($rule)',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      width: 300,
      decoration: cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(56, 56),
                      painter: RingPainter(
                        score / 100,
                        color: color,
                        stroke: 6,
                      ),
                    ),
                    Text(
                      '${score.round()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status keuangan',
                    style: TextStyle(fontSize: 10, color: SC.mute),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      labels[status] ?? 'Belum ada data',
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (actual.isNotEmpty) ...[
            const Divider(height: 22, color: SC.line),
            row('Kebutuhan', 'needs', 'maks. 50%'),
            row('Keinginan', 'wants', 'maks. 30%'),
            row('Tabungan', 'savings', 'min. 20%'),
          ],
        ],
      ),
    );
  }
}
