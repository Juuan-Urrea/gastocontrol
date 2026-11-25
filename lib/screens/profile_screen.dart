import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/validators.dart';

/// Perfil: datos de la cuenta (Firestore), alertas, notificaciones y cierre de sesion.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _income;
  late final TextEditingController _budget;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = AppController.to.profile;
    _name = TextEditingController(text: p.name);
    _income =
        TextEditingController(text: p.income > 0 ? p.income.toString() : '');
    _budget =
        TextEditingController(text: p.budget > 0 ? p.budget.toString() : '');
  }

  @override
  void dispose() {
    _name.dispose();
    _income.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    final ok = await AppController.to.updateProfile(
      name: _name.text,
      income: int.parse(_income.text),
      budget: int.parse(_budget.text),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok)
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Perfil actualizado.')));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppController.to;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, screenTopPadding(context), 16, 24),
      child: Form(
        key: _key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Perfil', style: outfit(24, weight: FontWeight.w700)),
            const SizedBox(height: 14),
            Obx(() {
              final p = state.profile;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: cardDecoration(radius: 18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primary.withOpacity(.25),
                      child: Text(p.avatar,
                          style: inter(18, weight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: inter(16, weight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(p.email,
                              style:
                                  inter(13, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                  labelText: 'Nombre', prefixIcon: Icon(Icons.person_outline)),
              validator: Validators.name,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _income,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: 'Ingreso mensual (COP)',
                  prefixIcon: Icon(Icons.trending_up)),
              validator: Validators.amount,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _budget,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: 'Presupuesto mensual (COP)',
                  prefixIcon: Icon(Icons.savings_outlined)),
              validator: Validators.amount,
            ),
            const SizedBox(height: 4),
            Text(
                'Ejemplo: ${formatCOP(2000000)} de ingreso y ${formatCOP(1200000)} de presupuesto.',
                style: inter(12, color: AppColors.mutedForeground)),
            const SizedBox(height: 14),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Guardando...' : 'Guardar cambios'),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: state.alertsEnabled,
                  onChanged: state.setAlertsEnabled,
                  title: Text('Alertas y notificaciones',
                      style: inter(14, weight: FontWeight.w600)),
                  subtitle: Text(
                      'Aviso al guardar un gasto y alertas de presupuesto.',
                      style: inter(12, color: AppColors.mutedForeground)),
                )),
            Obx(() => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_outlined),
                  title: Text('Ver notificaciones',
                      style: inter(14, weight: FontWeight.w600)),
                  trailing: state.unreadCount > 0
                      ? CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.primary,
                          child: Text('${state.unreadCount}',
                              style: inter(11, weight: FontWeight.w700)))
                      : const Icon(Icons.chevron_right),
                  onTap: () => state.go(AppScreen.notifications),
                )),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: state.logout,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
