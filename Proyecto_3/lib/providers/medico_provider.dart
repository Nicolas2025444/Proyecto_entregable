import 'package:flutter/foundation.dart';
import 'package:proyecto_3/data/models/medico.dart';
import 'package:proyecto_3/data/repositories/medico_repository.dart';

class MedicoProvider extends ChangeNotifier {
  MedicoProvider({MedicoRepository? medicoRepository})
      : _medicoRepository = medicoRepository ?? MedicoRepository();

  final MedicoRepository _medicoRepository;

  List<Medico> _medicos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Medico> get medicos => _medicos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadMedicos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _medicos = await _medicoRepository.getMedicos();
    } catch (e) {
      _errorMessage = _medicoRepository.resolveErrorMessage(e);
      _medicos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
