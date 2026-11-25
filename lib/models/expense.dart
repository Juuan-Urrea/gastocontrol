/// Un gasto registrado. [date] usa el formato "yyyy-MM-dd".
/// [isDemo] distingue los datos de ejemplo/prueba de los que registra el usuario.
class Expense {
  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.method,
    this.isDemo = false,
  });

  final String id;
  final int amount;
  final String category;
  final String description;
  final String date;
  final String method;
  final bool isDemo;

  Expense copyWith({
    int? amount,
    String? category,
    String? description,
    String? date,
    String? method,
  }) {
    return Expense(
      id: id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      method: method ?? this.method,
      isDemo: isDemo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category,
        'description': description,
        'date': date,
        'method': method,
        'isDemo': isDemo,
      };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      amount: (json['amount'] as num).toInt(),
      category: json['category'] as String,
      description: json['description'] as String,
      date: json['date'] as String,
      method: json['method'] as String,
      isDemo: (json['isDemo'] as bool?) ?? false,
    );
  }
}
