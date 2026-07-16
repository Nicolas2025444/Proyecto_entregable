class Cita {
  final int id;
  final DateTime fecha;
  final String motivo;
  final String? observaciones;
  final String estado; // 'pendiente', 'completada', 'cancelada'
  final int pacienteId;
  final String pacienteNombre;
  final int medicoId;
  final String medicoNombre;

  const Cita({
    required this.id,
    required this.fecha,
    required this.motivo,
    this.observaciones,
    required this.estado,
    required this.pacienteId,
    required this.pacienteNombre,
    required this.medicoId,
    required this.medicoNombre,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: _parseId(json['id']),
      fecha: _parseDateTime(json['fecha'] ?? json['fecha_hora'] ?? json['date']),
      motivo: json['motivo']?.toString() ?? '',
      observaciones: json['observaciones']?.toString() ?? json['observacion']?.toString(),
      estado: json['estado']?.toString() ?? 'pendiente',
      pacienteId: _parseId(json['pacienteId'] ?? json['paciente_id'] ?? json['id_paciente']),
      pacienteNombre: json['pacienteNombre']?.toString() ?? json['paciente_nombre']?.toString() ?? 'Paciente',
      medicoId: _parseId(json['medicoId'] ?? json['medico_id'] ?? json['id_medico']),
      medicoNombre: json['medicoNombre']?.toString() ?? json['medico_nombre']?.toString() ?? 'Médico',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'motivo': motivo,
      'observaciones': observaciones,
      'estado': estado,
      'pacienteId': pacienteId,
      'pacienteNombre': pacienteNombre,
      'medicoId': medicoId,
      'medicoNombre': medicoNombre,
    };
  }

  Cita copyWith({
    int? id,
    DateTime? fecha,
    String? motivo,
    String? observaciones,
    String? estado,
    int? pacienteId,
    String? pacienteNombre,
    int? medicoId,
    String? medicoNombre,
  }) {
    return Cita(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      motivo: motivo ?? this.motivo,
      observaciones: observaciones ?? this.observaciones,
      estado: estado ?? this.estado,
      pacienteId: pacienteId ?? this.pacienteId,
      pacienteNombre: pacienteNombre ?? this.pacienteNombre,
      medicoId: medicoId ?? this.medicoId,
      medicoNombre: medicoNombre ?? this.medicoNombre,
    );
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
