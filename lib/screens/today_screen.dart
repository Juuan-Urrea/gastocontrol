import 'package:flutter/material.dart';

import '../controllers/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'package:get/get.dart';
import '../widgets/expense_row.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) => Obx(() => _content(context, AppController.to));

  Widget _content(BuildContext context, AppController state) {
    final items = state.todayExpenses;
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gastos de hoy', style: outfit(25, weight: FontWeight.w700)),
                  const SizedBox(height: 5),
                  Text(formatDateFull(DateTime.now()), style: inter(13, color: AppColors.mutedForeground)),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(gradient: AppGradients.card, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TOTAL DE HOY', style: inter(11, weight: FontWeight.w700, color: AppColors.mutedForeground)),
                        const SizedBox(height: 5),
                        Text(formatCOP(state.todaySpent), style: outfit(29, weight: FontWeight.w700)),
                        Text('${items.length} movimientos registrados', style: inter(12, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.event_available, size: 42, color: AppColors.mutedForeground),
                            const SizedBox(height: 12),
                            Text('Todavía no registras gastos hoy.', style: inter(14, color: AppColors.mutedForeground)),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed: () => state.go(AppScreen.addExpense, tab: AppTab.add),
                              child: const Text('Registrar gasto'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 9),
                      itemBuilder: (_, i) => ExpenseRow(expense: items[i], onTap: () => state.openDetail(items[i])),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
