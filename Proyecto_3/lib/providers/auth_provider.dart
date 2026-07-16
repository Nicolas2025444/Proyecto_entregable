import 'package:flutter/foundation.dart';
import 'package:proyecto_3/data/models/user.dart';
import 'package:proyecto_3/data/repositories/auth_repository.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  final AuthRepository _authRepository;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _user != null;

  Future<void> restoreSession() async {
    _setLoading(true);
    _clearError();

    try {
      final restoredUser = await _authRepository.restoreSession();
      if (restoredUser != null) {
        _user = restoredUser;
        _status = AuthStatus.authenticated;
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
    } catch (error) {
      await _authRepository.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = _authRepository.resolveErrorMessage(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final loggedUser = await _authRepository.login(
        email: email,
        password: password,
      );

      _user = loggedUser;
      _status = AuthStatus.authenticated;
      return true;
    } catch (error) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = _authRepository.resolveErrorMessage(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authRepository.logout();
    } finally {
      _user = null;
      _status = AuthStatus.unauthenticated;
      _clearError();
      _setLoading(false);
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
