import 'package:proyecto_3/core/config/api_config.dart';
import 'package:proyecto_3/core/errors/api_exception.dart';
import 'package:proyecto_3/data/models/user.dart';
import 'package:proyecto_3/data/services/api_client.dart';

class AuthApi {
  AuthApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.loginPath,
        body: {
          'email': email.trim(),
          'password': password,
        },
      );

      return LoginResponse.fromJson(response);
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ParseException(
        'La respuesta de login no tiene el formato esperado.',
      );
    } catch (_) {
      throw const UnknownApiException(
        'No se pudo completar el inicio de sesión. Intenta de nuevo.',
      );
    }
  }
}
