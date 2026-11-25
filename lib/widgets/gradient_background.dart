import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fondo con degradado de las pantallas de acceso (splash, login, registro y configuracion).
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradients.screen),
      child: child,
    );
  }
}
