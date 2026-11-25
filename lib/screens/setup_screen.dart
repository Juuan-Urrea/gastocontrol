import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/validators.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _key = GlobalKey<FormState>();
  final _income = TextEditingController();
  final _budget = TextEditingController();

  @override
  void dispose() {
    _income.dispose();
    _budget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Configura tus finanzas', style: outfit(26, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Ingresa tu ingreso mensual y el presupuesto que quieres respetar.', style: inter(14, color: AppColors.mutedForeground)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _income,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Ingreso mensual (COP)', prefixIcon: Icon(Icons.trending_up)),
                  validator: Validators.amount,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _budget,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Presupuesto mensual (COP)', prefixIcon: Icon(Icons.savings_outlined)),
                  validator: Validators.amount,
                ),
                const SizedBox(height: 10),
                Text('Ejemplo: ${formatCOP(2000000)} de ingreso y ${formatCOP(1200000)} de presupuesto.', style: inter(12, color: AppColors.mutedForeground)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: () async {
                      if (!_key.currentState!.validate()) return;
                      await AppController.to.completeSetup(income: int.parse(_income.text), budget: int.parse(_budget.text));
                    },
                    child: const Text('Guardar configuración'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
