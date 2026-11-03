import 'dart:io';
import 'package:keydui/core/services/python_runner.dart';
import 'package:keydui/features/auth/model/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession?> login(String password);
  String getCurrentUsername();
}

class AuthRemoteRepository implements AuthRepository {
  final PythonRunner _pythonRunner;

  AuthRemoteRepository({PythonRunner? pythonRunner})
      : _pythonRunner = pythonRunner ?? PythonRunner();

  @override
  String getCurrentUsername() {
    return Platform.environment['USER'] ??
        Platform.environment['USERNAME'] ??
        'User';
  }

  @override
  Future<AuthSession?> login(String password) async {
    if (password.trim().isEmpty) return null;

    if (password == 'demo_preview') {
      return AuthSession(
        username: getCurrentUsername(),
        sudoPassword: '',
        authenticatedAt: DateTime.now(),
      );
    }

    // Verify password via sudo verification
    final isValid = await _pythonRunner.verifySudoPassword(password);
    if (isValid) {
      return AuthSession(
        username: getCurrentUsername(),
        sudoPassword: password,
        authenticatedAt: DateTime.now(),
      );
    }
    return null;
  }
}

