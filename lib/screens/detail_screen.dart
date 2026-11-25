import 'package:flutter/material.dart';
import '../models/categories.dart';
import '../controllers/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'package:get/get.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});
  @override
  Widget build(BuildContext context) => Obx(() => _content(context, AppController.to));

  Widget _content(BuildContext context, AppController state) {
    final expense = state.selectedExpense;
    if (expense == null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('No se encontró el gasto.'), TextButton(onPressed: state.back, child: const Text('Volver'))]));
    final category = categoryById(expense.category);
    return Container(color: AppColors.background, child: SafeArea(child: ListView(padding: const EdgeInsets.all(22), children: [
      Row(children: [IconButton(onPressed: state.back, icon: const Icon(Icons.arrow_back)), const SizedBox(width: 6), Text('Detalle del gasto', style: outfit(24, weight: FontWeight.w700))]),
      const SizedBox(height: 26),
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: AppGradients.card, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.white06)), child: Column(children: [Container(width: 70, height: 70, alignment: Alignment.center, decoration: BoxDecoration(color: category.color.withOpacity(.18), borderRadius: BorderRadius.circular(22)), child: Text(category.icon, style: const TextStyle(fontSize: 32))), const SizedBox(height: 18), Text(expense.description, textAlign: TextAlign.center, style: outfit(22, weight: FontWeight.w700)), const SizedBox(height: 8), Text('−${formatCOP(expense.amount)}', style: outfit(31, weight: FontWeight.w700, color: AppColors.danger)), const SizedBox(height: 22), const Divider(color: AppColors.white10), _DetailLine(label: 'Categoría', value: category.label), _DetailLine(label: 'Método de pago', value: expense.method), _DetailLine(label: 'Fecha', value: formatDateFull(parseDate(expense.date))), _DetailLine(label: 'Tipo de registro', value: expense.isDemo ? 'Dato de demostración' : 'Registrado por el usuario')])),
      const SizedBox(height: 20), SizedBox(height: 50, child: FilledButton.icon(onPressed: () => state.go(AppScreen.addExpense), icon: const Icon(Icons.edit_outlined), label: const Text('Editar gasto'), style: FilledButton.styleFrom(backgroundColor: AppColors.primary))), const SizedBox(height: 10),
      SizedBox(height: 50, child: OutlinedButton.icon(onPressed: () async { final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Eliminar gasto'), content: Text('¿Seguro que deseas eliminar “${expense.description}”? Esta acción no se puede deshacer.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar'))])); if (ok == true) { await state.deleteExpense(expense.id); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gasto eliminado.'))); } }, icon: const Icon(Icons.delete_outline), label: const Text('Eliminar gasto'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)))),
    ])));
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 11), child: Row(children: [Expanded(child: Text(label, style: inter(13, color: AppColors.mutedForeground))), Flexible(child: Text(value, textAlign: TextAlign.end, style: inter(13, weight: FontWeight.w600)))]));
}
