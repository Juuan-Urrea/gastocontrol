import 'package:flutter/material.dart';

import '../models/categories.dart';
import '../controllers/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'package:get/get.dart';
import '../widgets/expense_row.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'all';
  String _query = '';
  @override
  Widget build(BuildContext context) => Obx(() => _content(context, AppController.to));

  Widget _content(BuildContext context, AppController state) {
    final expenses = state.expensesForCategory(_filter).where((e) => e.description.toLowerCase().contains(_query.toLowerCase())).toList();
    return Container(color: AppColors.background, child: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Historial de gastos', style: outfit(25, weight: FontWeight.w700)), const SizedBox(height: 5),
        Text('${expenses.length} movimientos · Total ${formatCOP(expenses.fold<int>(0, (s, e) => s + e.amount))}', style: inter(13, color: AppColors.mutedForeground)), const SizedBox(height: 16),
        TextField(onChanged: (v) => setState(() => _query = v), decoration: InputDecoration(hintText: 'Buscar por descripción...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: AppColors.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: _filter, decoration: InputDecoration(labelText: 'Filtrar por categoría', filled: true, fillColor: AppColors.card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: [const DropdownMenuItem(value: 'all', child: Text('Todas las categorías')), ...kCategories.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.icon} ${c.label}')))], onChanged: (v) => setState(() => _filter = v ?? 'all')),
      ])),
      Expanded(child: expenses.isEmpty ? Center(child: Padding(padding: const EdgeInsets.all(28), child: Text('No hay gastos que coincidan con la búsqueda.', textAlign: TextAlign.center, style: inter(14, color: AppColors.mutedForeground)))) : ListView.separated(padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), itemCount: expenses.length, separatorBuilder: (_, __) => const SizedBox(height: 9), itemBuilder: (context, index) => ExpenseRow(expense: expenses[index], onTap: () => state.openDetail(expenses[index])))),
    ])));
  }
}
