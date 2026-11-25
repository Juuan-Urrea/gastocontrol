import 'package:flutter/material.dart';

import '../models/budget_status.dart';
import '../theme/app_theme.dart';

/// Barra de progreso del presupuesto (verde / ambar / rojo segun el estado), animada 600 ms.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.pct,
    required this.status,
    this.height = 8,
  });

  final num pct;
  final BudgetStatus status;
  final double height;

  @override
  Widget build(BuildContext context) {
    final factor = pct.clamp(0, 100).toDouble() / 100;
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white07,
        borderRadius: BorderRadius.circular(999),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: factor),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (context, value, _) => Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value,
            heightFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                color: budgetStatusColor(status),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
