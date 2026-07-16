class ApiConfig {
  ApiConfig._();

  /// Cambia a `false` cuando conectes contra el Swagger real.
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: true,
  );

  /// Emulador Android: 10.0.2.2 apunta al localhost de tu PC.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  static const String loginPath = '/auth/login';
  static const Duration timeout = Duration(seconds: 15);
}
