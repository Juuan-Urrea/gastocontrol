import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tarjeta de dato (etiqueta, valor en Outfit y subtitulo). Usar dentro de Expanded en una Row.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    this.color = AppColors.primary,
  });

  final String label;
  final String value;
  final String? sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: inter(12, color: AppColors.mutedForeground, height: 1.33)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: outfit(18, weight: FontWeight.w700, color: color, height: 1.55),
          ),
          if (sub != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(sub!, style: inter(12, color: AppColors.mutedForeground, height: 1.33)),
            ),
        ],
      ),
    );
  }
}
