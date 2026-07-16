import 'package:proyecto_3/core/config/api_config.dart';
import 'package:proyecto_3/core/errors/api_exception.dart';
import 'package:proyecto_3/data/datasources/cita_api.dart';
import 'package:proyecto_3/data/datasources/mock_cita_api.dart';
import 'package:proyecto_3/data/models/cita.dart';

class CitaRepository {
  CitaRepository({
    CitaApi? citaApi,
    MockCitaApi? mockCitaApi,
  })  : _citaApi = citaApi ?? CitaApi(),
        _mockCitaApi = mockCitaApi ?? MockCitaApi();

  final CitaApi _citaApi;
  final MockCitaApi _mockCitaApi;

  Future<List<Cita>> getCitas({int? pacienteId, int? medicoId}) async {
    if (ApiConfig.useMockApi) {
      return _mockCitaApi.getCitas(pacienteId: pacienteId, medicoId: medicoId);
    } else {
      return _citaApi.getCitas(pacienteId: pacienteId, medicoId: medicoId);
    }
  }

  Future<Cita> createCita({
    required int medicoId,
    required DateTime fecha,
    required String motivo,
  }) async {
    if (ApiConfig.useMockApi) {
      return _mockCitaApi.createCita(medicoId: medicoId, fecha: fecha, motivo: motivo);
    } else {
      return _citaApi.createCita(medicoId: medicoId, fecha: fecha, motivo: motivo);
    }
  }

  Future<Cita> updateCita(
    int id, {
    String? observaciones,
    String? estado,
  }) async {
    if (ApiConfig.useMockApi) {
      return _mockCitaApi.updateCita(id, observaciones: observaciones, estado: estado);
    } else {
      return _citaApi.updateCita(id, observaciones: observaciones, estado: estado);
    }
  }

  Future<void> deleteCita(int id) async {
    if (ApiConfig.useMockApi) {
      return _mockCitaApi.deleteCita(id);
    } else {
      return _citaApi.deleteCita(id);
    }
  }

  String resolveErrorMessage(Object error) {
    if (error is ApiException) return error.message;
    return 'Ocurrió un error inesperado al procesar la cita. Intenta de nuevo.';
  }
}
