/// Validaciones de formularios. Devuelven un mensaje de error o null si es valido.
class Validators {
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Ingresa tu correo electrónico';
    if (!_email.hasMatch(v)) return 'Ingresa un correo válido';
    return null;
  }

  static String? loginPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Ingresa tu contraseña';
    return null;
  }

  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Crea una contraseña';
    if (v.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  static String? name(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Ingresa tu nombre';
    if (v.length < 2) return 'El nombre es demasiado corto';
    return null;
  }

  /// Monto en COP: entero positivo.
  static String? amount(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Ingresa un valor';
    final n = int.tryParse(v);
    if (n == null) return 'Solo números enteros';
    if (n <= 0) return 'El valor debe ser mayor a 0';
    return null;
  }

  static String? description(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Escribe una descripción';
    return null;
  }
}
