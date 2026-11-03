import 'package:flutter/foundation.dart';
import 'package:keydui/features/auth/model/auth_session.dart';
import 'package:keydui/features/auth/repositories/auth_remote_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRemoteRepository();

  AuthSession? _session;
  bool _isLoading = false;
  String? _errorMessage;

  AuthSession? get session => _session;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _session != null;
  String get username => _repository.getCurrentUsername();

  Future<bool> login(String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await _repository.login(password);
      if (session != null) {
        _session = session;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Incorrect laptop password. Sudo authorization failed.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error authorizing: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _session = null;
    _errorMessage = null;
    notifyListeners();
  }
}

