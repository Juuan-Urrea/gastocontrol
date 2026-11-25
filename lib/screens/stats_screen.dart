import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(child: Obx(() {
    final state = AppController.to;
    final total = state.totalSpent;
    final categories = state.categoryTotals();
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text('Estadísticas', style: outfit(26, weight: FontWeight.w700)),
      Text(state.monthLabel),
      const SizedBox(height: 24),
      Text('Total gastado', style: inter(14)),
      Text(formatCOP(total), style: outfit(32, weight: FontWeight.w700)),
      Text('${state.monthlyExpenses.length} gastos registrados'),
      const SizedBox(height: 24),
      Text('Por categoría', style: outfit(20, weight: FontWeight.w700)),
      if (categories.isEmpty)
        const Padding(padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('Aún no tienes gastos registrados este mes.')),
      for (final item in categories)
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Row(children: [
            Expanded(child: Text('${item.category.icon}  ${item.category.label}')),
            Text(formatCOP(item.total)),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: item.total / total),
          Align(alignment: Alignment.centerRight,
            child: Text('${(100 * item.total / total).round()}%')),
        ]))),
    ]);
  }));
}
