import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/core.dart';
import 'features/auth/splash_screen.dart';

void main() => runApp(const ProviderScope(child: SakuinApp()));

class SakuinApp extends StatelessWidget {
  const SakuinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sakuin',
      debugShowCheckedModeBanner: false,
      theme: sakuinTheme(),
      home: const SplashScreen(),
    );
  }
}
