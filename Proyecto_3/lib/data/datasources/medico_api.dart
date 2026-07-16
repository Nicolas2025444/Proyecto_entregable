import 'package:proyecto_3/core/errors/api_exception.dart';
import 'package:proyecto_3/data/models/medico.dart';
import 'package:proyecto_3/data/services/api_client.dart';

class MedicoApi {
  MedicoApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Medico>> getMedicos() async {
    try {
      final response = await _apiClient.get('/medicos', requiresAuth: true);
      
      final dynamic rawList = response['data'] ?? response['medicos'] ?? response;
      if (rawList is List) {
        return rawList
            .map((item) => Medico.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      }
      
      // Si la API devuelve un objeto con un mapa vacío o similar
      if (response.isEmpty) return [];
      
      throw const ParseException('La respuesta de médicos no tiene el formato esperado.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const UnknownApiException('No se pudo obtener la lista de médicos. Intenta de nuevo.');
    }
  }
}
