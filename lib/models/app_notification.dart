enum NotificationType { warn, danger, info }

/// Notificacion de la app (alertas de presupuesto, gasto registrado, etc.).
/// [createdAt] son milisegundos desde epoch; sirve para ordenar y mostrar "hace X min".
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.read,
    required this.type,
    this.createdAt = 0,
  });

  final String id;
  final String title;
  final String message;
  final String time;
  final bool read;
  final NotificationType type;
  final int createdAt;

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      time: time,
      read: read ?? this.read,
      type: type,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'time': time,
        'read': read,
        'type': type.name,
        'createdAt': createdAt,
      };

  /// Lee una notificacion desde Firestore de forma tolerante: acepta documentos creados a mano
  /// en la consola (nombres en espanol, espacios extra, numeros/fechas/textos en cualquier tipo).
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // Claves normalizadas: minusculas y sin espacios, para tolerar "Title " o "TITLE".
    final data = <String, dynamic>{
      for (final e in json.entries) e.key.toString().trim().toLowerCase(): e.value,
    };

    dynamic pick(List<String> keys) {
      for (final k in keys) {
        final v = data[k];
        if (v != null && v.toString().trim().isNotEmpty) return v;
      }
      return null;
    }

    String text(List<String> keys, [String fallback = '']) =>
        pick(keys)?.toString().trim() ?? fallback;

    final rawRead = pick(['read', 'leido', 'leida', 'leído', 'leída']);
    final read = rawRead is bool ? rawRead : rawRead?.toString().toLowerCase() == 'true';

    final typeName = text(['type', 'tipo'], 'info').toLowerCase();

    return AppNotification(
      id: json['id'].toString(),
      title: text(['title', 'titulo', 'título', 'asunto', 'name'], 'Notificación'),
      message: text(['message', 'mensaje', 'body', 'texto', 'text', 'descripcion', 'descripción', 'content']),
      time: text(['time', 'tiempo', 'hora']),
      read: read,
      type: NotificationType.values.firstWhere(
        (t) => t.name == typeName,
        orElse: () => NotificationType.info,
      ),
      createdAt: _toMillis(pick(['createdat', 'created_at', 'fecha', 'timestamp'])),
    );
  }

  /// Acepta numeros, textos numericos y Timestamp de Firestore (cualquier objeto con
  /// millisecondsSinceEpoch). Si no se entiende, devuelve 0.
  static int _toMillis(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    try {
      return (v as dynamic).millisecondsSinceEpoch as int;
    } catch (_) {
      return 0;
    }
  }
}
