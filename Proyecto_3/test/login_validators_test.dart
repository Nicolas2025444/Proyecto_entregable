import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_3/ui/widgets/login_validators.dart';

void main() {
  group('LoginValidators', () {
    test('email returns error when empty', () {
      expect(LoginValidators.email(''), isNotNull);
      expect(LoginValidators.email(null), isNotNull);
    });

    test('email returns error for invalid format', () {
      expect(LoginValidators.email('correo-invalido'), isNotNull);
    });

    test('email accepts valid format', () {
      expect(LoginValidators.email('paciente@correo.com'), isNull);
    });

    test('password returns error when empty', () {
      expect(LoginValidators.password(''), isNotNull);
      expect(LoginValidators.password(null), isNotNull);
    });

    test('password accepts non-empty value', () {
      expect(LoginValidators.password('123456'), isNull);
    });
  });
}
