import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto_3/core/config/api_config.dart';
import 'package:proyecto_3/core/errors/api_exception.dart';
import 'package:proyecto_3/data/services/token_storage_service.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    TokenStorageService? tokenStorage,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  final http.Client _client;
  final TokenStorageService _tokenStorage;

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    bool requiresAuth = true,
  }) {
    return _send(
      method: 'GET',
      path: path,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) {
    return _send(
      method: 'PUT',
      path: path,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) {
    return _send(
      method: 'PATCH',
      path: path,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) {
    return _send(
      method: 'DELETE',
      path: path,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    required bool requiresAuth,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');

    try {
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      
      // LOGS para Punto de Control 2
      if (kDebugMode) {
        print('=== [ApiClient] REQUEST ===');
        print('Method: $method');
        print('URI: $uri');
        print('Headers: $headers');
        if (body != null) print('Body: $body');
      }

      final response = await _dispatch(method, uri, headers, body).timeout(
        ApiConfig.timeout,
        onTimeout: () {
          throw const NetworkException(
            'La solicitud tardó demasiado. Intenta de nuevo.',
          );
        },
      );

      // LOGS para Punto de Control 2
      if (kDebugMode) {
        print('=== [ApiClient] RESPONSE ===');
        print('Status Code: ${response.statusCode}');
        print('Body: ${response.body}');
        print('=============================');
      }

      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on HttpException {
      throw const NetworkException(
        'No se pudo establecer conexión con el servidor.',
      );
    } on FormatException {
      throw const ParseException();
    }
  }

  Future<http.Response> _dispatch(
    String method,
    Uri uri,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) {
    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      case 'PUT':
        return _client.put(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      case 'PATCH':
        return _client.patch(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      case 'DELETE':
        return _client.delete(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      default:
        throw ArgumentError('Método HTTP no soportado: $method');
    }
  }

  Future<Map<String, String>> _buildHeaders({required bool requiresAuth}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        throw const UnauthorizedException(
          'No hay sesión activa. Inicia sesión nuevamente.',
        );
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return {};
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const ParseException();
    }

    throw _mapStatusCodeToException(response);
  }

  ApiException _mapStatusCodeToException(http.Response response) {
    final message = _extractErrorMessage(response.body);

    return switch (response.statusCode) {
      400 || 422 => ValidationException(
          message ?? 'Los datos enviados no son válidos.',
        ),
      401 => UnauthorizedException(
          message ?? 'Credenciales incorrectas o sesión expirada.',
        ),
      404 => NotFoundException(
          message ?? 'El recurso solicitado no fue encontrado.',
        ),
      >= 500 => ServerException(
          message ?? 'Error interno del servidor. Intenta más tarde.',
        ),
      _ => UnknownApiException(
          message ?? 'Error inesperado (${response.statusCode}).',
        ),
    };
  }

  String? _extractErrorMessage(String body) {
    if (body.isEmpty) return null;

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        for (final key in ['message', 'error', 'detail', 'mensaje']) {
          final value = decoded[key];
          if (value != null && value.toString().trim().isNotEmpty) {
            return value.toString();
          }
        }
      }
    } on FormatException {
      return null;
    }

    return null;
  }

  void dispose() {
    _client.close();
  }
}
