import 'package:flutter/material.dart';

import '../models/categories.dart';
import '../models/expense.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'fade_up.dart';

/// Fila de un gasto: icono de categoria, descripcion, categoria · metodo, monto y fecha (MM-dd).
class ExpenseRow extends StatelessWidget {
  const ExpenseRow({super.key, required this.expense, required this.onTap});

  final Expense expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cat = categoryById(expense.category);
    return FadeUp(
      child: Material(
        color: AppColors.white03,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.white06),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cat.color.withOpacity(0.133),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(cat.icon, style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        expense.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: inter(14, weight: FontWeight.w500, height: 1.43),
                      ),
                      Text(
                        '${cat.label} · ${expense.method}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: inter(12, color: AppColors.mutedForeground, height: 1.33),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '−${formatCOP(expense.amount)}',
                      style: inter(14, weight: FontWeight.w600, color: AppColors.danger, height: 1.43),
                    ),
                    Text(
                      shortDate(expense.date),
                      style: inter(12, color: AppColors.mutedForeground, height: 1.33),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
