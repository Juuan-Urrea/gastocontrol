import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/categories.dart';
import '../models/expense.dart';
import '../controllers/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/validators.dart';

/// Formulario funcional de captura y edición de gastos.
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, this.expense});
  final Expense? expense;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _description;
  late String _category;
  late String _method;
  late DateTime _date;
  bool _saving = false;

  bool get _editing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _amount = TextEditingController(text: e == null ? '' : e.amount.toString());
    _description = TextEditingController(text: e?.description ?? '');
    _category = e?.category ?? kCategories.first.id;
    _method = e?.method ?? kPaymentMethods.first;
    _date = e == null ? DateTime.now() : parseDate(e.date);
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: AppColors.primary, surface: AppColors.card)), child: child!),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = int.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un monto mayor que cero.')));
      return;
    }
    setState(() => _saving = true);
    final state = AppController.to;
    final old = widget.expense;
    final expense = Expense(
      id: old?.id ?? AppController.newId(),
      amount: amount,
      category: _category,
      description: _description.text.trim(),
      date: dateToStr(_date),
      method: _method,
      isDemo: false,
    );
    if (old == null) {
      await state.addExpense(expense);
    } else {
      await state.updateExpense(expense);
      state.go(AppScreen.history, tab: AppTab.expenses);
    }
    if (!mounted) return;
    // Si el guardado fallo, seguimos en esta pantalla: se vuelve a habilitar el boton.
    setState(() => _saving = false);
  }

  InputDecoration _decoration(String label, {String? hint, Widget? prefix}) => InputDecoration(
    labelText: label, hintText: hint, prefixIcon: prefix,
    filled: true, fillColor: AppColors.white03,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.white10)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.white10)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
            children: [
              Text(_editing ? 'Editar gasto' : 'Registrar gasto', style: outfit(27, weight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Ingresa los datos del movimiento para mantener tus finanzas al día.', style: inter(14, color: AppColors.mutedForeground)),
              const SizedBox(height: 24),
              Text('MONTO DEL GASTO', style: inter(12, weight: FontWeight.w700, color: AppColors.mutedForeground)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amount, keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: outfit(26, weight: FontWeight.w700),
                decoration: _decoration('Monto en pesos colombianos', hint: 'Ej. 25000', prefix: const Icon(Icons.attach_money)),
                validator: (v) { final n = int.tryParse((v ?? '').trim()); if (n == null || n <= 0) return 'Ingresa un monto válido mayor que cero'; return null; },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _description, textCapitalization: TextCapitalization.sentences,
                decoration: _decoration('Descripción', hint: 'Ej. Almuerzo, transporte, mercado'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Describe en qué realizaste el gasto' : null,
                maxLength: 70,
              ),
              const SizedBox(height: 12),
              Text('CATEGORÍA', style: inter(12, weight: FontWeight.w700, color: AppColors.mutedForeground)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category, isExpanded: true, decoration: _decoration('Selecciona una categoría'),
                items: kCategories.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.icon}  ${c.label}'))).toList(),
                onChanged: (v) { if (v != null) setState(() => _category = v); },
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: _method, isExpanded: true, decoration: _decoration('Método de pago'),
                items: kPaymentMethods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) { if (v != null) setState(() => _method = v); },
              ),
              const SizedBox(height: 18),
              InkWell(
                borderRadius: BorderRadius.circular(14), onTap: _pickDate,
                child: InputDecorator(
                  decoration: _decoration('Fecha del gasto', prefix: const Icon(Icons.calendar_month_outlined)),
                  child: Row(children: [Expanded(child: Text(formatDateFull(_date))), const Icon(Icons.edit_calendar_outlined, color: AppColors.primary)]),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(height: 52, child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(_editing ? Icons.save_outlined : Icons.add_circle_outline),
                label: Text(_saving ? 'Guardando...' : _editing ? 'Guardar cambios' : 'Guardar gasto'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              )),
              const SizedBox(height: 10),
              Text('Los datos se guardan localmente en el dispositivo.', textAlign: TextAlign.center, style: inter(12, color: AppColors.mutedForeground)),
            ],
          ),
        ),
      ),
    );
  }
}
