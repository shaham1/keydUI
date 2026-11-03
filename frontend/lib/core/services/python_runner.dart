import 'dart:convert';
import 'dart:io';

/// Service responsible for invoking plain Python backend scripts and system commands.
class PythonRunner {
  final String pythonExecutable;
  String? _resolvedScriptPath;

  PythonRunner({
    this.pythonExecutable = 'python3',
  });

  /// Dynamically locates the backend script path across runtime contexts.
  String get scriptPath {
    if (_resolvedScriptPath != null) return _resolvedScriptPath!;

    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final homeDir = Platform.environment['HOME'] ?? '';

    final candidatePaths = [
      '$exeDir/backend/run.py',
      '$exeDir/data/backend/run.py',
      'backend/run.py',
      '../backend/run.py',
      '$homeDir/.local/share/keydui/backend/run.py',
      '/opt/keydui/backend/run.py',
      '/home/shaham/vscodeProjects/keydUI/backend/run.py',
    ];

    for (final path in candidatePaths) {
      if (File(path).existsSync()) {
        _resolvedScriptPath = path;
        return path;
      }
    }

    _resolvedScriptPath = candidatePaths.first;
    return _resolvedScriptPath!;
  }

  /// Invokes a plain Python function/script with arguments and optional standard input.
  Future<ProcessResult> runPython({
    required List<String> args,
    String? input,
  }) async {
    final targetScript = scriptPath;
    try {
      if (input != null && input.isNotEmpty) {
        final process = await Process.start(
          pythonExecutable,
          [targetScript, ...args],
        );
        process.stdin.write(input);
        await process.stdin.flush();
        await process.stdin.close();

        final stdout = await process.stdout.transform(utf8.decoder).join();
        final stderr = await process.stderr.transform(utf8.decoder).join();
        final exitCode = await process.exitCode;

        return ProcessResult(process.pid, exitCode, stdout, stderr);
      }

      final result = await Process.run(
        pythonExecutable,
        [targetScript, ...args],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
      return result;
    } catch (e) {
      return ProcessResult(
        -1,
        1,
        '',
        'Failed to execute python: $e',
      );
    }
  }

  /// Calls backend `get-profile` command to read ground-truth profile with SHA-256 hash.
  Future<Map<String, dynamic>?> getProfile({String? configPath}) async {
    final args = ['get-profile'];
    if (configPath != null) {
      args.addAll(['--config', configPath]);
    }

    final result = await runPython(args: args);
    if (result.exitCode == 0 && (result.stdout as String).isNotEmpty) {
      try {
        final data = jsonDecode(result.stdout as String);
        if (data is Map<String, dynamic> && data['success'] == true) {
          return data;
        }
      } catch (_) {}
    }
    return null;
  }

  /// Calls backend `save-profile` command with safe concurrency checks and validation.
  Future<Map<String, dynamic>> saveProfile({
    required String configContent,
    required String sudoPassword,
    String? baseHash,
    bool force = false,
  }) async {
    final args = ['save-profile'];
    if (force) args.add('--force');

    final payload = jsonEncode({
      'config': configContent,
      'sudo_password': sudoPassword,
      'base_hash': baseHash,
    });

    final result = await runPython(args: args, input: payload);
    try {
      final json = jsonDecode(result.stdout as String);
      return json as Map<String, dynamic>;
    } catch (_) {
      return {
        'success': false,
        'error': (result.stderr as String).isNotEmpty
            ? result.stderr
            : 'Unknown backend error while saving profile.',
      };
    }
  }

  /// Verifies the laptop sudo password via backend `verify-auth`.
  Future<bool> verifySudoPassword(String password) async {
    if (password.isEmpty) return false;

    final result = await runPython(
      args: ['verify-auth'],
      input: password,
    );

    if (result.exitCode == 0) {
      try {
        final data = jsonDecode(result.stdout as String);
        return data['success'] == true;
      } catch (_) {}
    }

    // Direct fallback if script was not reached
    try {
      final process = await Process.start('sudo', ['-k', '-S', 'true']);
      process.stdin.writeln(password);
      await process.stdin.flush();
      await process.stdin.close();
      return (await process.exitCode) == 0;
    } catch (_) {
      return false;
    }
  }

  /// Checks keyd daemon status via backend `get-status`.
  Future<Map<String, dynamic>?> getStatus() async {
    final result = await runPython(args: ['get-status']);
    if (result.exitCode == 0) {
      try {
        return jsonDecode(result.stdout as String);
      } catch (_) {}
    }
    return null;
  }
}
