import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SC {
  SC._();
  static const green = Color(0xFF2E9E5B);
  static const greenDark = Color(0xFF1F7A45);
  static const mint = Color(0xFFE6F4EC);
  static const bg = Color(0xFFF7FAF8);
  static const ink = Color(0xFF1C2A24);
  static const mute = Color(0xFF8A9A92);
  static const line = Color(0xFFE3ECE7);
  static const amber = Color(0xFFE0A030);
  static const blue = Color(0xFF4A7FC1);
  static const red = Color(0xFFE5675B);
  static const redSoft = Color(0xFFFDEEEC);
}

ThemeData sakuinTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: SC.green, primary: SC.green),
    scaffoldBackgroundColor: Colors.white,
  );
  return base.copyWith(
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      base.textTheme,
    ).apply(bodyColor: SC.ink, displayColor: SC.ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: SC.ink,
    ),
  );
}

BoxDecoration cardDeco({double radius = 18, Color color = Colors.white}) =>
    BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: SC.line),
    );

class SakuinLogo extends StatelessWidget {
  const SakuinLogo({super.key, this.size = 28, this.showText = true});
  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * .3),
            border: Border.all(color: SC.green, width: 2.2),
          ),
          child: Icon(
            Icons.north_east_rounded,
            color: SC.green,
            size: size * .55,
          ),
        ),
        if (showText) ...[
          SizedBox(width: size * .35),
          Text(
            'Sakuin',
            style: TextStyle(fontSize: size * .8, fontWeight: FontWeight.w700),
          ),
        ],
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.trailing,
    this.outlined = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? trailing;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: outlined ? SC.green : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                Icon(trailing, size: 18),
              ],
            ],
          );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: outlined
          ? OutlinedButton(
              onPressed: loading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: SC.ink,
                side: const BorderSide(color: SC.line),
                shape: shape,
              ),
              child: child,
            )
          : FilledButton(
              onPressed: loading ? null : onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: SC.green,
                foregroundColor: Colors.white,
                shape: shape,
              ),
              child: child,
            ),
    );
  }
}

OutlineInputBorder _border(Color c) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(14),
  borderSide: BorderSide(color: c),
);

class SakuinField extends StatelessWidget {
  const SakuinField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboard,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: SC.mute, fontSize: 14),
            prefixIcon: icon == null
                ? null
                : Icon(icon, size: 20, color: SC.mute),
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: _border(SC.line),
            enabledBorder: _border(SC.line),
            focusedBorder: _border(SC.green),
          ),
        ),
      ],
    );
  }
}

class FloatChip extends StatelessWidget {
  const FloatChip(this.text, {super.key, this.green = false, this.icon});
  final String text;
  final bool green;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: green ? SC.green : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: green ? Colors.white : SC.green),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: green ? Colors.white : SC.green,
            ),
          ),
        ],
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  RingPainter(
    this.progress, {
    this.color = SC.green,
    this.track = SC.mint,
    this.stroke = 10,
  });
  final double progress;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawArc(rect, 0, 6.2832, false, p);
    final double v = progress < 0 ? 0 : (progress > 1 ? 1 : progress);
    p.color = color;
    canvas.drawArc(rect, -1.5708, 6.2832 * v, false, p);
  }

  @override
  bool shouldRepaint(RingPainter old) =>
      old.progress != progress || old.color != color;
}
