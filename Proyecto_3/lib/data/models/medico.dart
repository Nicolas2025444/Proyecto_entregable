class Medico {
  final int id;
  final String email;
  final String nombre;
  final String apellido;
  final String especialidad;

  const Medico({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.especialidad,
  });

  factory Medico.fromJson(Map<String, dynamic> json) {
    return Medico(
      id: _parseId(json['id']),
      email: json['email']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      especialidad: json['especialidad']?.toString() ?? 'Medicina General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'especialidad': especialidad,
    };
  }

  String get nombreCompleto => 'Dr(a). $nombre $apellido';

  static int _parseId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
