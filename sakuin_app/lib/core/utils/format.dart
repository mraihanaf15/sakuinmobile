import 'package:flutter/material.dart';

num toNum(dynamic v) => v is num ? v : (num.tryParse('${v ?? 0}') ?? 0);

String rupiah(num v) {
  final neg = v < 0;
  final s = v.abs().round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${neg ? '-' : ''}Rp$buf';
}

const bucketLabels = {
  'needs': 'Kebutuhan',
  'wants': 'Keinginan',
  'savings': 'Tabungan',
};

String dateLabel(String ymd) {
  final d = DateTime.tryParse(ymd);
  if (d == null) return ymd;
  final n = DateTime.now();
  final diff = DateTime(
    n.year,
    n.month,
    n.day,
  ).difference(DateTime(d.year, d.month, d.day)).inDays;
  if (diff == 0) return 'Hari ini';
  if (diff == 1) return 'Kemarin';
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

IconData iconForCategory(String? name, bool income) {
  if (income) return Icons.arrow_upward_rounded;
  switch (name) {
    case 'Makan':
      return Icons.restaurant;
    case 'Transport':
      return Icons.directions_car_outlined;
    case 'Tagihan':
      return Icons.receipt_long_outlined;
    case 'Belanja':
      return Icons.shopping_bag_outlined;
    case 'Hiburan':
      return Icons.movie_outlined;
    case 'Kesehatan':
      return Icons.favorite_border;
    case 'Pendidikan':
      return Icons.school_outlined;
    case 'Tabungan':
    case 'Investasi':
      return Icons.savings_outlined;
    default:
      return Icons.more_horiz;
  }
}

class AppConfigHint {
  static String get adminUrl => const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  ).replaceAll('/api', '/admin');
}
