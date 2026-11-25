import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/validators.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_form.currentState!.validate()) return;
    final amount = int.parse(_amount.text);
    setState(() => _saving = true);
    final ok = await AppController.to.deposit(amount);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      _amount.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Depósito registrado por ${formatCOP(amount)}.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppController.to;
    return SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
      Row(children: [
        BackButton(onPressed: state.back),
        Text('Presupuesto', style: outfit(26, weight: FontWeight.w700)),
      ]),
      Obx(() => Text(state.monthLabel)),
      const SizedBox(height: 16),
      Obx(() => Card(child: Padding(padding: const EdgeInsets.all(16), child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Límite mensual    ${formatCOP(state.profile.budget)}'),
          Text('Gastado este mes    ${formatCOP(state.totalSpent)}'),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: state.budgetPct.clamp(0, 100) / 100),
          const SizedBox(height: 10),
          Text(state.available >= 0
              ? 'Disponible    ${formatCOP(state.available)}'
              : 'Exceso    ${formatCOP(-state.available)}',
              style: outfit(20, weight: FontWeight.w700)),
          TextButton(onPressed: () => state.go(AppScreen.profile),
              child: const Text('Editar presupuesto en Perfil')),
        ])))),
      const SizedBox(height: 24),
      Text('Saldo de la cuenta', style: outfit(20, weight: FontWeight.w700)),
      Obx(() => Text(formatCOP(state.accountBalance),
          style: outfit(30, weight: FontWeight.w700))),
      const Text('Depósitos acumulados menos todos los gastos registrados.'),
      const SizedBox(height: 16),
      Form(key: _form, child: TextFormField(controller: _amount,
          enabled: !_saving, keyboardType: TextInputType.number,
          maxLength: 12, inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Monto a depositar (COP)'),
          validator: Validators.amount)),
      FilledButton.icon(onPressed: _saving ? null : _submit,
          icon: const Icon(Icons.add), label: Text(_saving ? 'Guardando…' : 'Registrar depósito')),
    ]));
  }
}
