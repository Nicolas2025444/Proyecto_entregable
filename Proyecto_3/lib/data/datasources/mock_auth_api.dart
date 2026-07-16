import 'package:proyecto_3/core/errors/api_exception.dart';
import 'package:proyecto_3/data/models/user.dart';

class MockAuthApi {
  static const _mockDelay = Duration(milliseconds: 900);

  static const _pacienteEmail = 'paciente@correo.com';
  static const _medicoEmail = 'medico@correo.com';
  static const _validPassword = '123456';

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(_mockDelay);

    final normalizedEmail = email.trim().toLowerCase();

    if (password.isEmpty) {
      throw const ValidationException('La contraseña es obligatoria.');
    }

    if (password != _validPassword) {
      throw const UnauthorizedException('Correo o contraseña incorrectos.');
    }

    if (normalizedEmail == _pacienteEmail) {
      return LoginResponse(
        token: 'mock-jwt-paciente',
        user: const User(
          id: 1,
          email: _pacienteEmail,
          nombre: 'Ana',
          apellido: 'Paciente',
          rol: UserRole.paciente,
        ),
      );
    }

    if (normalizedEmail == _medicoEmail) {
      return LoginResponse(
        token: 'mock-jwt-medico',
        user: const User(
          id: 2,
          email: _medicoEmail,
          nombre: 'Carlos',
          apellido: 'Médico',
          rol: UserRole.medico,
        ),
      );
    }

    throw const UnauthorizedException('Correo o contraseña incorrectos.');
  }
}
