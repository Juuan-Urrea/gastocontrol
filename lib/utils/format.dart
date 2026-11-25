/// Formato de pesos colombianos: 15000 -> "$15.000".
String formatCOP(num n) {
  final negative = n < 0;
  final digits = n.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
  }
  return '${negative ? '-' : ''}\$$buffer';
}

/// Formato abreviado: 120000 -> "$120k".
String formatK(num n) => '\$${(n / 1000).toStringAsFixed(0)}k';

const List<String> _weekdays = [
  'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
];
const List<String> _months = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];
const List<String> _monthsShort = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// DateTime -> "yyyy-MM-dd".
String dateToStr(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

/// Fecha actual como "yyyy-MM-dd".
String todayStr() => dateToStr(DateTime.now());

String formatMonth(DateTime date) => '${_months[date.month - 1]} de ${date.year}';

/// "yyyy-MM-dd" -> DateTime (a las 12:00 para evitar saltos por zona horaria).
DateTime parseDate(String s) {
  final parts = s.split('-');
  if (parts.length != 3) return DateTime.now();
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return DateTime.now();
  return DateTime(y, m, d, 12);
}

/// "miércoles, 14 de octubre de 2026" (pantalla Hoy).
String formatDateFull(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} de ${_months[d.month - 1]} de ${d.year}';

/// "miércoles, 14 de oct" (encabezados del historial).
String formatDateHistory(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} de ${_monthsShort[d.month - 1]}';

/// "14 de octubre de 2026" (detalle del gasto).
String formatDateDetail(DateTime d) => '${d.day} de ${_months[d.month - 1]} de ${d.year}';

/// "MM-dd" a partir de "yyyy-MM-dd" (lista de gastos).
String shortDate(String s) => s.length >= 10 ? s.substring(5) : s;

/// Iniciales para el avatar: "Santiago Gómez" -> "SG".
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
}

/// "Ahora", "Hace 5 min", "Hace 2 h", "Hace 3 días" a partir de milisegundos desde epoch.
String timeAgo(int millis) {
  if (millis <= 0) return '';
  final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(millis));
  if (diff.inSeconds < 60) return 'Ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  return 'Hace ${diff.inDays} ${diff.inDays == 1 ? 'día' : 'días'}';
}
