import 'package:proyecto_3/core/config/api_config.dart';
import 'package:proyecto_3/core/errors/api_exception.dart';
import 'package:proyecto_3/data/datasources/medico_api.dart';
import 'package:proyecto_3/data/datasources/mock_medico_api.dart';
import 'package:proyecto_3/data/models/medico.dart';

class MedicoRepository {
  MedicoRepository({
    MedicoApi? medicoApi,
    MockMedicoApi? mockMedicoApi,
  })  : _medicoApi = medicoApi ?? MedicoApi(),
        _mockMedicoApi = mockMedicoApi ?? MockMedicoApi();

  final MedicoApi _medicoApi;
  final MockMedicoApi _mockMedicoApi;

  Future<List<Medico>> getMedicos() async {
    if (ApiConfig.useMockApi) {
      return _mockMedicoApi.getMedicos();
    } else {
      return _medicoApi.getMedicos();
    }
  }

  String resolveErrorMessage(Object error) {
    if (error is ApiException) return error.message;
    return 'Ocurrió un error inesperado al cargar médicos. Intenta de nuevo.';
  }
}
