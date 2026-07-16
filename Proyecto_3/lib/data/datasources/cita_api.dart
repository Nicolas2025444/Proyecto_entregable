import 'package:proyecto_3/core/errors/api_exception.dart';
import 'package:proyecto_3/data/models/cita.dart';
import 'package:proyecto_3/data/services/api_client.dart';

class CitaApi {
  CitaApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Cita>> getCitas({int? pacienteId, int? medicoId}) async {
    try {
      final queryParams = <String>[];
      if (pacienteId != null) queryParams.add('pacienteId=$pacienteId');
      if (medicoId != null) queryParams.add('medicoId=$medicoId');
      
      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final response = await _apiClient.get('/citas$queryString', requiresAuth: true);

      final dynamic rawList = response['data'] ?? response['citas'] ?? response;
      if (rawList is List) {
        return rawList
            .map((item) => Cita.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      if (response.isEmpty) return [];

      throw const ParseException('La respuesta de citas no tiene el formato esperado.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const UnknownApiException('No se pudieron obtener las citas. Intenta de nuevo.');
    }
  }

  Future<Cita> createCita({
    required int medicoId,
    required DateTime fecha,
    required String motivo,
  }) async {
    try {
      final response = await _apiClient.post(
        '/citas',
        body: {
          'medicoId': medicoId,
          'fecha': fecha.toIso8601String(),
          'motivo': motivo.trim(),
        },
        requiresAuth: true,
      );

      final dynamic rawCita = response['data'] ?? response['cita'] ?? response;
      if (rawCita is Map) {
        return Cita.fromJson(Map<String, dynamic>.from(rawCita));
      }
      
      throw const ParseException('La respuesta de creación de cita no tiene el formato esperado.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const UnknownApiException('No se pudo registrar la cita. Intenta de nuevo.');
    }
  }

  Future<Cita> updateCita(
    int id, {
    String? observaciones,
    String? estado,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (observaciones != null) body['observaciones'] = observaciones.trim();
      if (estado != null) body['estado'] = estado;

      final response = await _apiClient.put(
        '/citas/$id',
        body: body,
        requiresAuth: true,
      );

      final dynamic rawCita = response['data'] ?? response['cita'] ?? response;
      if (rawCita is Map) {
        return Cita.fromJson(Map<String, dynamic>.from(rawCita));
      }

      throw const ParseException('La respuesta de actualización de cita no tiene el formato esperado.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const UnknownApiException('No se pudo actualizar la cita. Intenta de nuevo.');
    }
  }

  Future<void> deleteCita(int id) async {
    try {
      await _apiClient.delete(
        '/citas/$id',
        requiresAuth: true,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const UnknownApiException('No se pudo cancelar la cita. Intenta de nuevo.');
    }
  }
}
