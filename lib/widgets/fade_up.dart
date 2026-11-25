import 'package:flutter/material.dart';

/// Animacion de entrada del prototipo (.animate-fade-up): aparece subiendo 16 px en 400 ms.
class FadeUp extends StatelessWidget {
  const FadeUp({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child),
      ),
    );
  }
}
