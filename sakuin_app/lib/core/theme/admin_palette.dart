import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet admin. Ubah [primary] (mis. ke Color(0xFF2E9E5B)) untuk menyamakan dengan tema pengguna.
class AdminPalette {
  const AdminPalette({
    required this.bg,
    required this.surface,
    required this.ink,
    required this.mute,
    required this.line,
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.onPrimary,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.shadow,
  });

  final Color bg, surface, ink, mute, line;
  final Color primary, primaryDark, primarySoft, onPrimary;
  final Color success,
      successSoft,
      warning,
      warningSoft,
      danger,
      dangerSoft,
      shadow;

  static const light = AdminPalette(
    bg: Color(0xFFF6F7FB),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF1B1E32),
    mute: Color(0xFF7B829B),
    line: Color(0xFFE6E8F1),
    primary: Color(0xFF4F46E5),
    primaryDark: Color(0xFF3730A3),
    primarySoft: Color(0xFFEEF0FF),
    onPrimary: Color(0xFFFFFFFF),
    success: Color(0xFF059669),
    successSoft: Color(0xFFD9F7EA),
    warning: Color(0xFFD97706),
    warningSoft: Color(0xFFFDF0D3),
    danger: Color(0xFFDC143C),
    dangerSoft: Color(0xFFFCE4E9),
    shadow: Color(0x141B1E32),
  );

  static const dark = AdminPalette(
    bg: Color(0xFF0E1020),
    surface: Color(0xFF171A2E),
    ink: Color(0xFFEDEFFA),
    mute: Color(0xFF9096B3),
    line: Color(0xFF292D49),
    primary: Color(0xFF818CF8),
    primaryDark: Color(0xFF6366F1),
    primarySoft: Color(0xFF23274A),
    onPrimary: Color(0xFF0E1020),
    success: Color(0xFF34D399),
    successSoft: Color(0xFF123A2E),
    warning: Color(0xFFFBBF24),
    warningSoft: Color(0xFF3F3216),
    danger: Color(0xFFFB7185),
    dangerSoft: Color(0xFF3F1A24),
    shadow: Color(0x66000000),
  );
}

extension AdminContext on BuildContext {
  AdminPalette get ap => Theme.of(this).brightness == Brightness.dark
      ? AdminPalette.dark
      : AdminPalette.light;
}

ThemeData adminThemeData(Brightness b) {
  final p = b == Brightness.dark ? AdminPalette.dark : AdminPalette.light;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AdminPalette.light.primary,
        brightness: b,
      ).copyWith(
        primary: p.primary,
        onPrimary: p.onPrimary,
        surface: p.surface,
        onSurface: p.ink,
        error: p.danger,
      );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.bg,
    brightness: b,
  );
  return base.copyWith(
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      base.textTheme,
    ).apply(bodyColor: p.ink, displayColor: p.ink),
    dividerColor: p.line,
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      indicatorColor: p.primarySoft,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontSize: 11,
          fontWeight: s.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: s.contains(WidgetState.selected) ? p.primary : p.mute,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? p.primary : p.mute,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: p.surface,
      indicatorColor: p.primarySoft,
      selectedIconTheme: IconThemeData(color: p.primary),
      unselectedIconTheme: IconThemeData(color: p.mute),
      selectedLabelTextStyle: TextStyle(
        color: p.primary,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: TextStyle(color: p.mute, fontSize: 12),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : p.mute,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.primary : p.line,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
  );
}
