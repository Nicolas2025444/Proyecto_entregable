import 'package:flutter/foundation.dart';
import 'package:proyecto_3/data/models/cita.dart';
import 'package:proyecto_3/data/repositories/cita_repository.dart';

class CitaProvider extends ChangeNotifier {
  CitaProvider({CitaRepository? citaRepository})
      : _citaRepository = citaRepository ?? CitaRepository();

  final CitaRepository _citaRepository;

  List<Cita> _citas = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Cita> get citas => _citas;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  List<Cita> get pendingCitas => _citas.where((c) => c.estado == 'pendiente').toList();
  List<Cita> get historyCitas => _citas.where((c) => c.estado != 'pendiente').toList();

  Future<void> loadCitas({int? pacienteId, int? medicoId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _citas = await _citaRepository.getCitas(pacienteId: pacienteId, medicoId: medicoId);
    } catch (e) {
      _errorMessage = _citaRepository.resolveErrorMessage(e);
      _citas = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCita({
    required int medicoId,
    required DateTime fecha,
    required String motivo,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newCita = await _citaRepository.createCita(
        medicoId: medicoId,
        fecha: fecha,
        motivo: motivo,
      );
      _citas.insert(0, newCita);
      return true;
    } catch (e) {
      _errorMessage = _citaRepository.resolveErrorMessage(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> cancelCita(int id) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _citaRepository.deleteCita(id);
      
      final index = _citas.indexWhere((c) => c.id == id);
      if (index != -1) {
        _citas[index] = _citas[index].copyWith(estado: 'cancelada');
      }
      return true;
    } catch (e) {
      _errorMessage = _citaRepository.resolveErrorMessage(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> completeCita(
    int id, {
    required String observaciones,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedCita = await _citaRepository.updateCita(
        id,
        observaciones: observaciones,
        estado: 'completada',
      );

      final index = _citas.indexWhere((c) => c.id == id);
      if (index != -1) {
        _citas[index] = updatedCita;
      }
      return true;
    } catch (e) {
      _errorMessage = _citaRepository.resolveErrorMessage(e);
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
