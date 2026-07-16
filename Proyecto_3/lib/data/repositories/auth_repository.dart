import 'package:proyecto_3/core/config/api_config.dart';
import 'package:proyecto_3/core/errors/api_exception.dart';
import 'package:proyecto_3/data/datasources/auth_api.dart';
import 'package:proyecto_3/data/datasources/mock_auth_api.dart';
import 'package:proyecto_3/data/models/user.dart';
import 'package:proyecto_3/data/services/session_storage_service.dart';

class AuthRepository {
  AuthRepository({
    AuthApi? authApi,
    MockAuthApi? mockAuthApi,
    SessionStorageService? sessionStorage,
  })  : _authApi = authApi ?? AuthApi(),
        _mockAuthApi = mockAuthApi ?? MockAuthApi(),
        _sessionStorage = sessionStorage ?? SessionStorageService();

  final AuthApi _authApi;
  final MockAuthApi _mockAuthApi;
  final SessionStorageService _sessionStorage;

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final loginResponse = ApiConfig.useMockApi
        ? await _mockAuthApi.login(email: email, password: password)
        : await _authApi.login(email: email, password: password);

    await _sessionStorage.saveSession(
      token: loginResponse.token,
      user: loginResponse.user,
    );

    return loginResponse.user;
  }

  Future<User?> restoreSession() async {
    final hasSession = await _sessionStorage.hasActiveSession();
    if (!hasSession) return null;
    return _sessionStorage.getUser();
  }

  Future<void> logout() => _sessionStorage.clearSession();

  String resolveErrorMessage(Object error) {
    if (error is ApiException) return error.message;
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
