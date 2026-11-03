class KeydConfig {
  final List<String> ids;
  final Map<String, Map<String, String>> layers;
  final String? contentHash;

  KeydConfig({
    List<String>? ids,
    Map<String, Map<String, String>>? layers,
    this.contentHash,
  })  : ids = ids ?? ['*'],
        layers = layers ?? {
          'main': {},
        };

  KeydConfig copyWith({
    List<String>? ids,
    Map<String, Map<String, String>>? layers,
    String? contentHash,
  }) {
    return KeydConfig(
      ids: ids ?? List.from(this.ids),
      layers: layers ??
          this.layers.map(
                (k, v) => MapEntry(k, Map<String, String>.from(v)),
              ),
      contentHash: contentHash ?? this.contentHash,
    );
  }

  static const Map<String, List<String>> _keyAliases = {
    'comma': [',', 'comma'],
    ',': ['comma', ','],
    'dot': ['.', 'dot'],
    '.': ['dot', '.'],
    'slash': ['/', 'slash'],
    '/': ['slash', '/'],
    'semicolon': [';', 'semicolon'],
    ';': ['semicolon', ';'],
    'apostrophe': ['\'', 'apostrophe'],
    '\'': ['apostrophe', '\''],
    'leftbrace': ['[', 'leftbrace'],
    '[': ['leftbrace', '['],
    'rightbrace': [']', 'rightbrace'],
    ']': ['rightbrace', ']'],
    'backslash': ['\\', 'backslash'],
    '\\': ['backslash', '\\'],
    'minus': ['-', 'minus'],
    '-': ['minus', '-'],
    'equal': ['=', 'equal'],
    '=': ['equal', '='],
    'escape': ['esc', 'escape'],
    'esc': ['escape', 'esc'],
    'leftalt': ['alt', 'leftalt'],
    'rightalt': ['rightalt', 'alt'],
    'alt': ['leftalt', 'rightalt', 'alt'],
    'leftcontrol': ['ctrl', 'control', 'leftcontrol'],
    'rightcontrol': ['rightcontrol', 'control', 'ctrl'],
    'control': ['leftcontrol', 'rightcontrol', 'control', 'ctrl'],
    'leftshift': ['shift', 'leftshift'],
    'rightshift': ['rightshift', 'shift'],
    'shift': ['leftshift', 'rightshift', 'shift'],
    'leftmeta': ['meta', 'leftmeta'],
    'rightmeta': ['rightmeta', 'meta'],
    'meta': ['leftmeta', 'rightmeta', 'meta'],
    'capslock': ['caps', 'capslock'],
    'caps': ['capslock', 'caps'],
  };

  /// Sets or updates a key mapping in a layer.
  void setMapping(String layer, String keyId, String action) {
    if (!layers.containsKey(layer)) {
      layers[layer] = {};
    }
    final aliases = _keyAliases[keyId];
    if (aliases != null) {
      for (final alias in aliases) {
        layers[layer]!.remove(alias);
      }
    }
    layers[layer]![keyId] = action;
  }

  /// Removes a key mapping in a layer, restoring default behavior.
  void removeMapping(String layer, String keyId) {
    if (layers.containsKey(layer)) {
      layers[layer]!.remove(keyId);
      final aliases = _keyAliases[keyId];
      if (aliases != null) {
        for (final alias in aliases) {
          layers[layer]!.remove(alias);
        }
      }
    }
  }

  /// Returns the remapped action for a key in a given layer, or null if unmapped.
  String? getMapping(String layer, String keyId) {
    final layerMap = layers[layer];
    if (layerMap == null) return null;

    if (layerMap.containsKey(keyId)) {
      return layerMap[keyId];
    }

    final aliases = _keyAliases[keyId];
    if (aliases != null) {
      for (final alias in aliases) {
        if (layerMap.containsKey(alias)) {
          return layerMap[alias];
        }
      }
    }
    return null;
  }

  /// Constructs a KeydConfig directly from the backend's `get-profile` response.
  factory KeydConfig.fromBackendJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final idsRaw = data['ids'] as List<dynamic>? ?? ['*'];
    final ids = idsRaw.map((e) => e.toString()).toList();

    final layersRaw = data['layers'] as Map<String, dynamic>? ?? {};
    final Map<String, Map<String, String>> layers = {};

    for (final entry in layersRaw.entries) {
      if (entry.value is Map) {
        layers[entry.key] = (entry.value as Map).map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }
    }

    if (!layers.containsKey('main')) {
      layers['main'] = {};
    }

    final hash = json['hash']?.toString() ?? data['content_hash']?.toString();

    return KeydConfig(
      ids: ids,
      layers: layers,
      contentHash: hash,
    );
  }

  /// Parses keyd config file string (.conf) into KeydConfig.
  factory KeydConfig.parse(String content, [String? contentHash]) {
    final List<String> ids = [];
    final Map<String, Map<String, String>> layers = {};
    String currentSection = '';

    final lines = content.split('\n');
    for (var rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      if (line.startsWith('[') && line.endsWith(']')) {
        currentSection = line.substring(1, line.length - 1).trim();
        if (currentSection != 'ids' && !layers.containsKey(currentSection)) {
          layers[currentSection] = {};
        }
        continue;
      }

      if (currentSection == 'ids') {
        ids.add(line);
      } else if (currentSection.isNotEmpty) {
        final separatorIndex = line.indexOf('=');
        if (separatorIndex != -1) {
          final key = line.substring(0, separatorIndex).trim();
          final val = line.substring(separatorIndex + 1).trim();
          layers.putIfAbsent(currentSection, () => {})[key] = val;
        }
      }
    }

    if (!layers.containsKey('main')) {
      layers['main'] = {};
    }

    return KeydConfig(
      ids: ids.isEmpty ? ['*'] : ids,
      layers: layers,
      contentHash: contentHash,
    );
  }

  /// Serializes KeydConfig into valid keyd .conf format.
  String toConfString() {
    final buffer = StringBuffer();

    buffer.writeln('[ids]');
    for (final id in ids) {
      buffer.writeln(id);
    }
    buffer.writeln();

    for (final entry in layers.entries) {
      buffer.writeln('[${entry.key}]');
      for (final mapping in entry.value.entries) {
        buffer.writeln('${mapping.key} = ${mapping.value}');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Provides initial default configuration matching the existing system.
  factory KeydConfig.defaultConfig() {
    return KeydConfig(
      ids: ['*'],
      layers: {
        'main': {
          'rightcontrol': 'backslash',
          'rightalt': 'escape',
          'capslock': 'overload(code, capslock)',
          'escape': 'overload(nums, escape)',
        },
        'nums': {
          'q': 'numlock',
          'alt': 'backspace',
          'space': '0',
          'n': 'kp1',
          'm': 'kp2',
          ',': 'kp3',
          'j': 'kp4',
          'k': 'kp5',
          'l': 'kp6',
          'u': 'kp7',
          'i': 'kp8',
          'o': 'kp9',
        },
        'code': {
          '*': 'noop',
          'h': 'left',
          'j': 'down',
          'k': 'up',
          'l': 'right',
          'u': 'pageup',
          'o': 'pagedown',
          'n': 'C-tab',
          'b': 'C-S-tab',
          'c': 'leftmouse',
          'm': 'rightmouse',
          'a': 'rightcontrol',
          's': 'rightshift',
          'd': 'overload(nums, d)',
          'f': 'escape',
          'space': 'backspace',
          'i': 'macro(<-)',
          ';': 'macro(<>)',
          '\\': '~',
          ',': 'macro(<> left)',
          'r': 'macro(python3)',
          'alt': 'alt',
          'meta': 'meta',
          'tab': 'tab',
        },
      },
    );
  }
}
