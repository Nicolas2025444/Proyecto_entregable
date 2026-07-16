sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'Sin conexión a internet. Verifica tu red e intenta de nuevo.',
  ]);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Credenciales incorrectas o sesión expirada.',
  ]);
}

class NotFoundException extends ApiException {
  const NotFoundException([
    super.message = 'El recurso solicitado no fue encontrado.',
  ]);
}

class ServerException extends ApiException {
  const ServerException([
    super.message = 'Error interno del servidor. Intenta más tarde.',
  ]);
}

class ValidationException extends ApiException {
  const ValidationException(super.message);
}

class ParseException extends ApiException {
  const ParseException([
    super.message = 'No se pudo procesar la respuesta del servidor.',
  ]);
}

class UnknownApiException extends ApiException {
  const UnknownApiException([
    super.message = 'Ocurrió un error inesperado. Intenta de nuevo.',
  ]);
}
