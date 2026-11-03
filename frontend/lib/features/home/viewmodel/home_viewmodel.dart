import 'package:flutter/foundation.dart';
import 'package:keydui/features/home/model/keyd_config.dart';
import 'package:keydui/features/home/repositories/keyd_remote_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final KeydRepository _repository;

  HomeViewModel({KeydRepository? repository})
      : _repository = repository ?? KeydRemoteRepository();

  KeydConfig? _config;
  KeydConfig? _originalConfig;
  String _activeLayer = 'main';
  String? _selectedKeyId;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  String? _statusMessage;
  List<String> _availableKeys = [];

  KeydConfig? get config => _config;
  String get activeLayer => _activeLayer;
  String? get selectedKeyId => _selectedKeyId;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  String? get statusMessage => _statusMessage;
  List<String> get availableKeys => _availableKeys;

  List<String> get layers => _config?.layers.keys.toList() ?? ['main'];

  String? get currentKeyMapping {
    if (_selectedKeyId == null || _config == null) return null;
    return _config!.getMapping(_activeLayer, _selectedKeyId!);
  }

  Future<void> init() async {
    await refreshProfile();
  }

  /// Reloads the ground-truth profile from disk via the backend on launch or refresh.
  Future<void> refreshProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _config = await _repository.loadConfig();
      _originalConfig = _config?.copyWith();
      _availableKeys = await _repository.getAvailableKeydKeys();
      if (!_config!.layers.containsKey(_activeLayer)) {
        _activeLayer = _config!.layers.keys.firstOrNull ?? 'main';
      }
      _hasUnsavedChanges = false;
    } catch (e) {
      _statusMessage = 'Failed to load keyd configuration: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectLayer(String layer) {
    if (_activeLayer != layer) {
      _activeLayer = layer;
      notifyListeners();
    }
  }

  void addLayer(String layerName) {
    final cleanName = layerName.trim().toLowerCase();
    if (cleanName.isEmpty || _config == null) return;

    if (!_config!.layers.containsKey(cleanName)) {
      _config!.layers[cleanName] = {};
      _activeLayer = cleanName;
      _hasUnsavedChanges = true;
      notifyListeners();
    }
  }

  void deleteLayer(String layerName) {
    if (layerName == 'main' || _config == null) return;

    if (_config!.layers.containsKey(layerName)) {
      _config!.layers.remove(layerName);
      if (_activeLayer == layerName) {
        _activeLayer = 'main';
      }
      _hasUnsavedChanges = true;
      notifyListeners();
    }
  }

  void selectKey(String? keyId) {
    _selectedKeyId = keyId;
    notifyListeners();
  }

  void remapCurrentKey(String newAction) {
    if (_selectedKeyId == null || _config == null) return;

    _config!.setMapping(_activeLayer, _selectedKeyId!, newAction.trim());
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void resetCurrentKey() {
    if (_selectedKeyId == null || _config == null) return;

    _config!.removeMapping(_activeLayer, _selectedKeyId!);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  Future<bool> saveAndReload(String sudoPassword) async {
    if (_config == null) return false;

    _isSaving = true;
    _statusMessage = 'Validating and reloading keyd...';
    notifyListeners();

    try {
      final saveResult = await _repository.saveAndApplyConfig(
        config: _config!,
        sudoPassword: sudoPassword,
      );

      if (saveResult.success) {
        if (saveResult.newHash != null) {
          _config = _config!.copyWith(contentHash: saveResult.newHash);
        }
        _originalConfig = _config?.copyWith();
        _hasUnsavedChanges = false;
        _statusMessage = 'Configuration applied & keyd reloaded successfully!';
        _isSaving = false;
        notifyListeners();
        return true;
      } else {
        _statusMessage = saveResult.errorMessage ?? 'Failed to apply configuration.';
        _isSaving = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _statusMessage = 'Error applying config: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  void discardChanges() {
    if (_originalConfig != null) {
      _config = _originalConfig!.copyWith();
      _hasUnsavedChanges = false;
      _statusMessage = 'Changes discarded.';
      notifyListeners();
    }
  }
}
