import 'package:proyecto_3/data/models/cita.dart';

class MockCitaApi {
  static const _mockDelay = Duration(milliseconds: 600);

  // Lista en memoria mutable para simular base de datos
  final List<Cita> _mockCitas = [
    Cita(
      id: 101,
      fecha: DateTime.now().add(const Duration(days: 1, hours: 2)),
      motivo: 'Chequeo de presión arterial y dolor de cabeza constante',
      observaciones: null,
      estado: 'pendiente',
      pacienteId: 1,
      pacienteNombre: 'Ana Paciente',
      medicoId: 2,
      medicoNombre: 'Dr(a). Carlos Médico',
    ),
    Cita(
      id: 102,
      fecha: DateTime.now().add(const Duration(days: 2, hours: 4)),
      motivo: 'Revisión pediátrica anual de crecimiento',
      observaciones: 'El niño muestra un crecimiento excelente en percentiles.',
      estado: 'completada',
      pacienteId: 1,
      pacienteNombre: 'Ana Paciente',
      medicoId: 3,
      medicoNombre: 'Dr(a). Sofía Valenzuela',
    ),
    Cita(
      id: 103,
      fecha: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
      motivo: 'Dolor de garganta severo y fiebre',
      observaciones: 'Se recetó descanso e ibuprofeno.',
      estado: 'completada',
      pacienteId: 1,
      pacienteNombre: 'Ana Paciente',
      medicoId: 4,
      medicoNombre: 'Dr(a). Fernando Gómez',
    ),
  ];

  Future<List<Cita>> getCitas({int? pacienteId, int? medicoId}) async {
    await Future<void>.delayed(_mockDelay);
    
    var filtered = List<Cita>.from(_mockCitas);
    if (pacienteId != null) {
      filtered = filtered.where((c) => c.pacienteId == pacienteId).toList();
    }
    if (medicoId != null) {
      filtered = filtered.where((c) => c.medicoId == medicoId).toList();
    }
    
    filtered.sort((a, b) => b.fecha.compareTo(a.fecha));
    return filtered;
  }

  Future<Cita> createCita({
    required int medicoId,
    required DateTime fecha,
    required String motivo,
  }) async {
    await Future<void>.delayed(_mockDelay);

    String medicoNombre = 'Dr. Médico';
    if (medicoId == 2) medicoNombre = 'Dr(a). Carlos Médico';
    if (medicoId == 3) medicoNombre = 'Dr(a). Sofía Valenzuela';
    if (medicoId == 4) medicoNombre = 'Dr(a). Fernando Gómez';
    if (medicoId == 5) medicoNombre = 'Dr(a). Lucía Mendoza';

    final newCita = Cita(
      id: DateTime.now().millisecondsSinceEpoch,
      fecha: fecha,
      motivo: motivo,
      observaciones: null,
      estado: 'pendiente',
      pacienteId: 1,
      pacienteNombre: 'Ana Paciente',
      medicoId: medicoId,
      medicoNombre: medicoNombre,
    );

    _mockCitas.add(newCita);
    return newCita;
  }

  Future<Cita> updateCita(
    int id, {
    String? observaciones,
    String? estado,
  }) async {
    await Future<void>.delayed(_mockDelay);

    final index = _mockCitas.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw Exception('Cita no encontrada');
    }

    final oldCita = _mockCitas[index];
    final updatedCita = oldCita.copyWith(
      observaciones: observaciones ?? oldCita.observaciones,
      estado: estado ?? oldCita.estado,
    );

    _mockCitas[index] = updatedCita;
    return updatedCita;
  }

  Future<void> deleteCita(int id) async {
    await Future<void>.delayed(_mockDelay);
    
    final index = _mockCitas.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw Exception('Cita no encontrada');
    }
    
    final oldCita = _mockCitas[index];
    _mockCitas[index] = oldCita.copyWith(estado: 'cancelada');
  }
}
