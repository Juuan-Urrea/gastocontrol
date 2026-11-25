import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

/// Pantalla TEMPORAL para las secciones que aun no tienen su interfaz final
/// (Estadisticas y Presupuesto). Muestra el estado de la conexion con Firebase.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  void _toast(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Obx(() => _content(context, AppController.to));

  Widget _content(BuildContext context, AppController s) {
    final muted = inter(13, color: AppColors.mutedForeground, height: 1.5);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, screenTopPadding(context), 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: outfit(24, weight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Pantalla pendiente de diseño.', style: muted),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: cardDecoration(radius: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estado de la conexión con Firebase', style: inter(13, weight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text('Sesión: ${s.isLoggedIn ? "iniciada" : "cerrada"}', style: muted),
                Text('Cuenta: ${s.profile.name} · ${s.profile.email}', style: muted),
                Text('UID: ${s.uid ?? "-"}', style: muted),
                Text('Gastos en tiempo real: ${s.expenses.length}', style: muted),
                Text('Total gastado: ${formatCOP(s.totalSpent)}', style: muted),
                Text('Presupuesto: ${formatCOP(s.profile.budget)} (${s.budgetPct}%)', style: muted),
                Text('Notificaciones sin leer: ${s.unreadCount}', style: muted),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: () async {
                  final n = await s.addTodayTestExpenses();
                  _toast(context, n == 0 ? 'Los gastos de prueba de hoy ya estaban cargados' : 'Se agregaron $n gastos de prueba con la fecha de hoy');
                },
                child: const Text('Cargar gastos de prueba (hoy)'),
              ),
              OutlinedButton(
                onPressed: () async {
                  final n = await s.removeDemoExpenses();
                  _toast(context, 'Se quitaron $n gastos de ejemplo/prueba');
                },
                child: const Text('Quitar datos de ejemplo'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
