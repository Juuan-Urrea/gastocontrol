import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Boton principal (violeta, esquinas 16, texto Outfit semibold 16).
/// Mientras [loading] es true muestra [loadingLabel] y se atenua.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading && onPressed != null;
    final background = active
        ? AppColors.primary
        : AppColors.primary.withOpacity(loading ? 0.5 : 0.4);
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: active ? onPressed : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Text(
            loading ? (loadingLabel ?? label) : label,
            style: outfit(16, weight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
