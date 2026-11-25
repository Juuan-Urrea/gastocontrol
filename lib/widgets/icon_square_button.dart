import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Boton cuadrado con esquinas 12 y fondo translucido (atras, editar, campana).
class IconSquareButton extends StatelessWidget {
  const IconSquareButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.size = 36,
    this.iconSize = 20,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: AppColors.white07,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: iconSize, color: AppColors.foreground),
          ),
        ),
      ),
    );
  }
}
