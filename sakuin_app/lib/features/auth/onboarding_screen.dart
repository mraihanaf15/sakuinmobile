import 'package:flutter/material.dart';

import '../../core/core.dart';
import 'welcome_screen.dart';

class _Slide {
  const _Slide(this.title, this.sub);
  final String title;
  final String sub;
}

const _slides = [
  _Slide(
    'Atur uang dengan metode 50/30/20',
    'Bagi pemasukan untuk kebutuhan, keinginan, dan masa depan secara lebih terarah.',
  ),
  _Slide(
    'Catat pemasukan & pengeluaran dengan mudah',
    'Simpan setiap transaksi dalam hitungan detik dan pantau arus kasmu kapan saja.',
  ),
  _Slide(
    'Tanya AI untuk cek kesehatan keuanganmu',
    'Dapatkan analisis personal dan saran praktis berdasarkan kebiasaan finansialmu.',
  ),
];

const _badges = [
  ['20%', '50%'],
  ['+ Pemasukan', '- Pengeluaran'],
  ['Sehat', 'AI'],
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pc = PageController();
  int _i = 0;

  void _finish() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
  );

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  Widget _bar(Color c) => Container(
    height: 7,
    decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
  );

  Widget _legend(Color c, String l, String v) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(child: Text(l, style: const TextStyle(fontSize: 9))),
        Text(
          v,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  Widget _iconBox(IconData i) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: SC.mint,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(i, color: SC.green, size: 20),
  );

  Widget _row(String l, String v, Color c) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Expanded(child: Text(l, style: const TextStyle(fontSize: 10))),
        Text(
          v,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c),
        ),
      ],
    ),
  );

  Widget _card(int i) {
    switch (i) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconBox(Icons.bar_chart_rounded),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(flex: 50, child: _bar(SC.green)),
                const SizedBox(width: 3),
                Expanded(flex: 30, child: _bar(SC.amber)),
                const SizedBox(width: 3),
                Expanded(flex: 20, child: _bar(SC.blue)),
              ],
            ),
            const SizedBox(height: 6),
            _legend(SC.green, 'Kebutuhan', '50%'),
            _legend(SC.amber, 'Keinginan', '30%'),
            _legend(SC.blue, 'Tabungan', '20%'),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconBox(Icons.swap_vert_rounded),
            const SizedBox(height: 6),
            _row('Gaji bulanan', '+Rp8.000.000', SC.green),
            _row('Makan siang', '-Rp48.000', SC.ink),
            _row('Transport', '-Rp32.000', SC.ink),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconBox(Icons.auto_awesome),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: SC.greenDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Apakah keuangan saya sehat?',
                style: TextStyle(color: Colors.white, fontSize: 9),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(44, 44),
                        painter: RingPainter(.82, stroke: 5),
                      ),
                      const Text(
                        '82',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Keuanganmu sehat',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _illustration(int i) {
    return SizedBox(
      width: 290,
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: SC.line),
            ),
          ),
          Container(
            width: 170,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: _card(i),
          ),
          Positioned(
            top: 20,
            right: 0,
            child: FloatChip(_badges[i][0], green: true),
          ),
          Positioned(bottom: 40, left: 0, child: FloatChip(_badges[i][1])),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final last = _i == _slides.length - 1;
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SakuinLogo(),
                    TextButton(
                      onPressed: _finish,
                      child: const Text(
                        'Lewati',
                        style: TextStyle(color: SC.mute, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pc,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _i = i),
                    itemBuilder: (_, i) => Column(
                      children: [
                        Expanded(child: Center(child: _illustration(i))),
                        Text(
                          _slides[i].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            height: 1.25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _slides[i].sub,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: SC.mute,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (k) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: k == _i ? 22 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: k == _i ? SC.green : SC.line,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: last ? 'Mulai sekarang' : 'Lanjut',
                  trailing: Icons.chevron_right_rounded,
                  onPressed: () {
                    if (last) {
                      _finish();
                    } else {
                      _pc.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
