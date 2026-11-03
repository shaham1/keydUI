import 'dart:io';
import 'package:keydui/core/services/python_runner.dart';
import 'package:keydui/features/home/model/keyd_config.dart';

class KeydSaveResult {
  final bool success;
  final String? errorMessage;
  final String? newHash;
  final bool isConflict;

  const KeydSaveResult({
    required this.success,
    this.errorMessage,
    this.newHash,
    this.isConflict = false,
  });
}

abstract class KeydRepository {
  Future<KeydConfig> loadConfig();
  Future<KeydSaveResult> saveAndApplyConfig({
    required KeydConfig config,
    required String sudoPassword,
  });
  Future<List<String>> getAvailableKeydKeys();
}

class KeydRemoteRepository implements KeydRepository {
  final PythonRunner _pythonRunner;
  final String configPath;

  KeydRemoteRepository({
    PythonRunner? pythonRunner,
    this.configPath = '/etc/keyd/default.conf',
  }) : _pythonRunner = pythonRunner ?? PythonRunner();

  @override
  Future<KeydConfig> loadConfig() async {
    // 1. First attempt: Use the backend service to get the ground truth profile and content hash
    try {
      final backendData = await _pythonRunner.getProfile(configPath: configPath);
      if (backendData != null) {
        return KeydConfig.fromBackendJson(backendData);
      }
    } catch (_) {}

    // 2. Second attempt: Direct file read if backend CLI wasn't reached
    try {
      final file = File(configPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        return KeydConfig.parse(content);
      }
    } catch (_) {}

    // 3. Fallback: Default safe configuration matching the system
    return KeydConfig.defaultConfig();
  }

  @override
  Future<KeydSaveResult> saveAndApplyConfig({
    required KeydConfig config,
    required String sudoPassword,
  }) async {
    final confString = config.toConfString();

    // Invoke Python backend service with baseHash concurrency protection
    final response = await _pythonRunner.saveProfile(
      configContent: confString,
      sudoPassword: sudoPassword,
      baseHash: config.contentHash,
    );

    if (response['success'] == true) {
      return KeydSaveResult(
        success: true,
        newHash: response['hash'] as String?,
      );
    }

    final isConflict = response['code'] == 'CONFLICT_DETECTED';
    final errorMsg = response['error']?.toString() ??
        'Failed to save configuration and reload keyd.';

    return KeydSaveResult(
      success: false,
      errorMessage: errorMsg,
      isConflict: isConflict,
    );
  }

  @override
  Future<List<String>> getAvailableKeydKeys() async {
    try {
      final result = await Process.run('keyd', ['list-keys']);
      if (result.exitCode == 0) {
        final lines = (result.stdout as String)
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        return lines;
      }
    } catch (_) {}

    return [
      'escape', 'backspace', 'tab', 'enter', 'space', 'capslock',
      'leftcontrol', 'rightcontrol', 'leftalt', 'rightalt', 'leftshift', 'rightshift', 'leftmeta', 'rightmeta',
      'left', 'right', 'up', 'down', 'home', 'end', 'pageup', 'pagedown', 'insert', 'delete',
      'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12',
      'leftmouse', 'rightmouse', 'middlemouse', 'noop'
    ];
  }
}
