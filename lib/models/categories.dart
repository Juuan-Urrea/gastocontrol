import 'package:flutter/material.dart';

/// Categoria de gasto (id, nombre, emoji y color), igual al prototipo.
class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String id;
  final String label;
  final String icon;
  final Color color;
}

const List<ExpenseCategory> kCategories = [
  ExpenseCategory(id: 'food', label: 'Alimentación', icon: '🍔', color: Color(0xFF7C6FEA)),
  ExpenseCategory(id: 'transport', label: 'Transporte', icon: '🚌', color: Color(0xFF00D4A0)),
  ExpenseCategory(id: 'entertainment', label: 'Entretenimiento', icon: '🎬', color: Color(0xFFF59E0B)),
  ExpenseCategory(id: 'health', label: 'Salud', icon: '💊', color: Color(0xFFEF4444)),
  ExpenseCategory(id: 'education', label: 'Educación', icon: '📚', color: Color(0xFF3B82F6)),
  ExpenseCategory(id: 'clothing', label: 'Ropa', icon: '👕', color: Color(0xFFEC4899)),
  ExpenseCategory(id: 'home', label: 'Hogar', icon: '🏠', color: Color(0xFF8B5CF6)),
  ExpenseCategory(id: 'other', label: 'Otros', icon: '📦', color: Color(0xFF6B7280)),
];

/// Metodos de pago del prototipo.
const List<String> kPaymentMethods = [
  'Efectivo',
  'Tarjeta débito',
  'Tarjeta crédito',
  'Transferencia',
  'Nequi/Daviplata',
];

/// Busca una categoria por id; si no existe devuelve "Otros".
ExpenseCategory categoryById(String id) {
  for (final c in kCategories) {
    if (c.id == id) return c;
  }
  return kCategories.last;
}
