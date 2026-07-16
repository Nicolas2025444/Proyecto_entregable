import 'package:proyecto_3/data/models/medico.dart';

class MockMedicoApi {
  static const _mockDelay = Duration(milliseconds: 700);

  final List<Medico> _mockMedicos = const [
    Medico(
      id: 2,
      email: 'medico@correo.com',
      nombre: 'Carlos',
      apellido: 'Médico',
      especialidad: 'Cardiología',
    ),
    Medico(
      id: 3,
      email: 'sofia.pediatra@correo.com',
      nombre: 'Sofía',
      apellido: 'Valenzuela',
      especialidad: 'Pediatría',
    ),
    Medico(
      id: 4,
      email: 'fernando.general@correo.com',
      nombre: 'Fernando',
      apellido: 'Gómez',
      especialidad: 'Medicina General',
    ),
    Medico(
      id: 5,
      email: 'lucia.derma@correo.com',
      nombre: 'Lucía',
      apellido: 'Mendoza',
      especialidad: 'Dermatología',
    ),
  ];

  Future<List<Medico>> getMedicos() async {
    await Future<void>.delayed(_mockDelay);
    return _mockMedicos;
  }
}
