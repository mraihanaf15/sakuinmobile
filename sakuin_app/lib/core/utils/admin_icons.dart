import 'package:flutter/material.dart';

/// Kunci ikon sama dengan kolom `icon` pada tabel categories di backend.
const adminIconOptions = <String, IconData>{
  'restaurant': Icons.restaurant,
  'directions_car': Icons.directions_car_outlined,
  'receipt_long': Icons.receipt_long_outlined,
  'favorite': Icons.favorite_border,
  'school': Icons.school_outlined,
  'shopping_bag': Icons.shopping_bag_outlined,
  'movie': Icons.movie_outlined,
  'savings': Icons.savings_outlined,
  'trending_up': Icons.trending_up_rounded,
  'more_horiz': Icons.more_horiz_rounded,
  'payments': Icons.payments_outlined,
  'work': Icons.work_outline_rounded,
  'card_giftcard': Icons.card_giftcard_outlined,
  'home': Icons.home_outlined,
  'phone_android': Icons.phone_android_outlined,
  'coffee': Icons.coffee_outlined,
  'sports_esports': Icons.sports_esports_outlined,
  'flight': Icons.flight_outlined,
};

IconData adminIcon(String key) =>
    adminIconOptions[key] ?? Icons.category_outlined;

IconData tipCategoryIcon(String c) {
  switch (c) {
    case 'anggaran':
      return Icons.pie_chart_outline_rounded;
    case 'menabung':
      return Icons.savings_outlined;
    case 'pengeluaran':
      return Icons.receipt_long_outlined;
    case 'darurat':
      return Icons.shield_outlined;
    case 'gaya-hidup':
      return Icons.local_cafe_outlined;
    default:
      return Icons.lightbulb_outline_rounded;
  }
}
