import 'package:flutter/material.dart';

import '../models/categories.dart';
import '../controllers/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'package:get/get.dart';
import '../widgets/expense_row.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => Obx(() => _content(context, AppController.to));

  Widget _content(BuildContext context, AppController state) {
    final recent = state.expenses.take(4).toList();
    final pct = state.budgetPct.clamp(0, 100) / 100;
    return Container(
      color: AppColors.background,
      child: SafeArea(child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hola, ${state.profile.name.split(' ').first}', style: outfit(25, weight: FontWeight.w700)),
              const SizedBox(height: 4), Text(formatDateFull(DateTime.now()), style: inter(13, color: AppColors.mutedForeground)),
            ])),
            IconButton(
              onPressed: () => state.go(AppScreen.notifications),
              icon: Badge(
                isLabelVisible: state.unreadCount > 0,
                label: Text('${state.unreadCount}'),
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
            CircleAvatar(backgroundColor: AppColors.primary.withOpacity(.25), child: Text(state.profile.avatar, style: inter(15, weight: FontWeight.w700))),
          ]),
          const SizedBox(height: 22),
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: AppGradients.budgetCard, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DISPONIBLE DEL PRESUPUESTO', style: inter(11, weight: FontWeight.w700, color: const Color(0xFFB8B4F8))),
            const SizedBox(height: 8), Text(formatCOP(state.available), style: outfit(31, weight: FontWeight.w700, color: state.available < 0 ? AppColors.danger : AppColors.foreground)),
            const SizedBox(height: 4), Text('Presupuesto: ${formatCOP(state.profile.budget)}', style: inter(13, color: AppColors.mutedForeground)),
            const SizedBox(height: 18),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: AppColors.white10, valueColor: AlwaysStoppedAnimation(state.budgetPct >= 100 ? AppColors.danger : state.budgetPct >= 80 ? AppColors.warn : AppColors.accent))),
            const SizedBox(height: 8), Row(children: [Expanded(child: Text('${state.budgetPct}% utilizado', style: inter(12, color: AppColors.mutedForeground))), Text('${formatCOP(state.totalSpent)} gastados', style: inter(12, weight: FontWeight.w600))]),
          ])),
          TextButton.icon(
            onPressed: () => state.go(AppScreen.budget),
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text('Ver presupuesto y depositar dinero'),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _MetricCard(title: 'Gasto de hoy', amount: formatCOP(state.todaySpent), icon: Icons.today_outlined, color: AppColors.accent)),
            const SizedBox(width: 12),
            Expanded(child: _MetricCard(title: 'Ingresos del mes', amount: formatCOP(state.profile.income), icon: Icons.account_balance_wallet_outlined, color: AppColors.primary)),
          ]),
          const SizedBox(height: 24),
          Row(children: [Expanded(child: Text('Gastos recientes', style: outfit(19, weight: FontWeight.w700))), TextButton(onPressed: () => state.go(AppScreen.history, tab: AppTab.expenses), child: const Text('Ver historial'))]),
          if (recent.isEmpty) _EmptyCard(onAdd: () => state.go(AppScreen.addExpense)) else ...recent.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: ExpenseRow(expense: e, onTap: () => state.openDetail(e)))),
          const SizedBox(height: 12),
          SizedBox(height: 50, child: FilledButton.icon(onPressed: () => state.go(AppScreen.addExpense, tab: AppTab.add), icon: const Icon(Icons.add), label: const Text('Registrar nuevo gasto'), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
          const SizedBox(height: 24),
          Text('Gastos del mes por categoría', style: outfit(19, weight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (state.categoryTotals().isEmpty) Text('Cuando registres gastos, aquí verás el resumen por categoría.', style: inter(13, color: AppColors.mutedForeground))
          else ...state.categoryTotals().take(4).map((t) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [Text(categoryById(t.category.id).icon, style: const TextStyle(fontSize: 20)), const SizedBox(width: 10), Expanded(child: Text(t.category.label, style: inter(14))), Text(formatCOP(t.total), style: inter(14, weight: FontWeight.w600))]))),
        ],
      )),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.amount, required this.icon, required this.color});
  final String title, amount;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(17), border: Border.all(color: AppColors.white06)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color), const SizedBox(height: 12), Text(title, style: inter(12, color: AppColors.mutedForeground)), const SizedBox(height: 4), Text(amount, maxLines: 1, overflow: TextOverflow.ellipsis, style: outfit(19, weight: FontWeight.w700))]));
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)), child: Column(children: [const Icon(Icons.receipt_long_outlined, size: 34, color: AppColors.mutedForeground), const SizedBox(height: 8), Text('Aún no hay movimientos', style: inter(14, weight: FontWeight.w600)), const SizedBox(height: 6), Text('Registra tu primer gasto para comenzar.', style: inter(12, color: AppColors.mutedForeground)), TextButton(onPressed: onAdd, child: const Text('Agregar gasto'))]));
}
