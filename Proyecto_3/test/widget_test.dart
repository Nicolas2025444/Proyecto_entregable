import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_3/data/datasources/mock_auth_api.dart';
import 'package:proyecto_3/data/models/user.dart';

void main() {
  group('MockAuthApi', () {
    final mockApi = MockAuthApi();

    test('login returns paciente role', () async {
      final response = await mockApi.login(
        email: 'paciente@correo.com',
        password: '123456',
      );

      expect(response.user.rol, UserRole.paciente);
      expect(response.token, isNotEmpty);
    });

    test('login returns medico role', () async {
      final response = await mockApi.login(
        email: 'medico@correo.com',
        password: '123456',
      );

      expect(response.user.rol, UserRole.medico);
    });
  });
}
