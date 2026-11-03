import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keydui/core/theme/app_palette.dart';
import 'package:keydui/core/utils/keyd_key_mapper.dart';
import 'package:keydui/features/home/viewmodel/home_viewmodel.dart';

class RemappingDrawer extends StatefulWidget {
  final HomeViewModel viewModel;

  const RemappingDrawer({
    super.key,
    required this.viewModel,
  });

  @override
  State<RemappingDrawer> createState() => _RemappingDrawerState();
}

class _RemappingDrawerState extends State<RemappingDrawer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _customExpressionController = TextEditingController();
  final TextEditingController _overloadTapKeyController = TextEditingController();
  String? _selectedOverloadLayer;
  String? _lastPressedKeyFeedback;

  static final List<String> _letters = 'abcdefghijklmnopqrstuvwxyz'.split('');
  static final List<String> _numbers = '1234567890'.split('');

  static const List<Map<String, String>> _symbols = [
    {'id': '-', 'label': '- (Minus)'},
    {'id': '=', 'label': '= (Equal)'},
    {'id': '[', 'label': '[ (Left Brace)'},
    {'id': ']', 'label': '] (Right Brace)'},
    {'id': '\\', 'label': '\\ (Backslash)'},
    {'id': ';', 'label': '; (Semicolon)'},
    {'id': '\'', 'label': '\' (Apostrophe)'},
    {'id': '`', 'label': '` (Grave / Tilde)'},
    {'id': ',', 'label': ', (Comma)'},
    {'id': '.', 'label': '. (Period / Dot)'},
    {'id': '/', 'label': '/ (Slash)'},
  ];

  static const List<Map<String, String>> _numpadKeys = [
    {'id': 'numlock', 'label': 'NumLock'},
    {'id': 'kpslash', 'label': 'KP / (Divide)'},
    {'id': 'kpasterisk', 'label': 'KP * (Multiply)'},
    {'id': 'kpminus', 'label': 'KP - (Subtract)'},
    {'id': 'kp7', 'label': 'KP 7'},
    {'id': 'kp8', 'label': 'KP 8'},
    {'id': 'kp9', 'label': 'KP 9'},
    {'id': 'kpplus', 'label': 'KP + (Add)'},
    {'id': 'kp4', 'label': 'KP 4'},
    {'id': 'kp5', 'label': 'KP 5'},
    {'id': 'kp6', 'label': 'KP 6'},
    {'id': 'kpequal', 'label': 'KP = (Equal)'},
    {'id': 'kp1', 'label': 'KP 1'},
    {'id': 'kp2', 'label': 'KP 2'},
    {'id': 'kp3', 'label': 'KP 3'},
    {'id': 'kpenter', 'label': 'KP Enter'},
    {'id': 'kp0', 'label': 'KP 0'},
    {'id': 'kpdot', 'label': 'KP . (Decimal)'},
  ];

  static const List<Map<String, String>> _functionKeys = [
    {'id': 'f1', 'label': 'F1'},
    {'id': 'f2', 'label': 'F2'},
    {'id': 'f3', 'label': 'F3'},
    {'id': 'f4', 'label': 'F4'},
    {'id': 'f5', 'label': 'F5'},
    {'id': 'f6', 'label': 'F6'},
    {'id': 'f7', 'label': 'F7'},
    {'id': 'f8', 'label': 'F8'},
    {'id': 'f9', 'label': 'F9'},
    {'id': 'f10', 'label': 'F10'},
    {'id': 'f11', 'label': 'F11'},
    {'id': 'f12', 'label': 'F12'},
  ];

  static const List<Map<String, String>> _navigationKeys = [
    {'id': 'up', 'label': '▲ Up Arrow'},
    {'id': 'down', 'label': '▼ Down Arrow'},
    {'id': 'left', 'label': '◀ Left Arrow'},
    {'id': 'right', 'label': '▶ Right Arrow'},
    {'id': 'insert', 'label': 'Insert'},
    {'id': 'delete', 'label': 'Delete'},
    {'id': 'home', 'label': 'Home'},
    {'id': 'end', 'label': 'End'},
    {'id': 'pageup', 'label': 'Page Up'},
    {'id': 'pagedown', 'label': 'Page Down'},
    {'id': 'print', 'label': 'PrintScreen'},
    {'id': 'scrolllock', 'label': 'ScrollLock'},
    {'id': 'pause', 'label': 'Pause / Break'},
  ];

  static const List<Map<String, String>> _modifiersAndSystem = [
    {'id': 'leftcontrol', 'label': 'Ctrl (Left)'},
    {'id': 'rightcontrol', 'label': 'Ctrl (Right)'},
    {'id': 'leftalt', 'label': 'Alt (Left)'},
    {'id': 'rightalt', 'label': 'Alt (Right)'},
    {'id': 'leftmeta', 'label': 'Meta / Super'},
    {'id': 'rightmeta', 'label': 'Meta (Right)'},
    {'id': 'leftshift', 'label': 'Shift (Left)'},
    {'id': 'rightshift', 'label': 'Shift (Right)'},
    {'id': 'capslock', 'label': 'CapsLock'},
    {'id': 'tab', 'label': 'Tab'},
    {'id': 'enter', 'label': 'Enter'},
    {'id': 'space', 'label': 'Space'},
    {'id': 'backspace', 'label': 'Backspace'},
    {'id': 'escape', 'label': 'Escape'},
  ];

  static const List<Map<String, String>> _mediaAndMouse = [
    {'id': 'volumeup', 'label': 'Volume Up'},
    {'id': 'volumedown', 'label': 'Volume Down'},
    {'id': 'mute', 'label': 'Mute Audio'},
    {'id': 'playpause', 'label': 'Play / Pause'},
    {'id': 'nextsong', 'label': 'Next Track'},
    {'id': 'previoussong', 'label': 'Prev Track'},
    {'id': 'stopcd', 'label': 'Stop Media'},
    {'id': 'leftmouse', 'label': 'Left Click'},
    {'id': 'rightmouse', 'label': 'Right Click'},
    {'id': 'middlemouse', 'label': 'Middle Click'},
    {'id': 'noop', 'label': 'Disable Key (noop)'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    HardwareKeyboard.instance.addHandler(_handlePhysicalKeyPress);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handlePhysicalKeyPress);
    _tabController.dispose();
    _customExpressionController.dispose();
    _overloadTapKeyController.dispose();
    super.dispose();
  }

  bool _handlePhysicalKeyPress(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    // Do not intercept if user is typing in a text field
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus != null && primaryFocus.context != null) {
      final editable = primaryFocus.context!.findAncestorWidgetOfExactType<EditableText>();
      if (editable != null) return false;
    }

    if (widget.viewModel.selectedKeyId == null) return false;

    final keydName = KeydKeyMapper.fromKeyEvent(event);
    if (keydName != null) {
      widget.viewModel.remapCurrentKey(keydName);
      setState(() {
        _lastPressedKeyFeedback = keydName;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _lastPressedKeyFeedback = null);
      });
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final selectedKeyId = widget.viewModel.selectedKeyId;
    final currentMapping = widget.viewModel.currentKeyMapping;

    if (selectedKeyId == null) {
      final activeLayer = widget.viewModel.activeLayer;
      final mappingsCount =
          widget.viewModel.config?.layers[activeLayer]?.length ?? 0;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: const BoxDecoration(
          color: Palette.cardColor,
          border: Border(
            top: BorderSide(color: Palette.borderColor, width: 1.0),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Palette.surfaceColor,
                borderRadius: BorderRadius.circular(Palette.radiusMedium),
                border: Border.all(color: Palette.borderColor, width: 1.0),
              ),
              child: const Icon(
                Icons.touch_app_rounded,
                color: Palette.accentBright,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select a key to remap',
                    style: TextStyle(
                      color: Palette.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Click any keycap above to configure remapping or press any physical key directly.',
                    style: const TextStyle(
                      color: Palette.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Palette.surfaceColor,
                borderRadius: BorderRadius.circular(Palette.radiusSmall),
                border: Border.all(color: Palette.borderColor, width: 1.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Palette.accentCyan,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$mappingsCount Remapped on [$activeLayer]',
                    style: const TextStyle(
                      color: Palette.accentCyan,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final layers = widget.viewModel.layers;
    _selectedOverloadLayer ??= layers.firstWhere(
      (l) => l != widget.viewModel.activeLayer,
      orElse: () => layers.first,
    );

    return Container(
      height: 290,
      decoration: const BoxDecoration(
        color: Palette.cardColor,
        border: Border(
          top: BorderSide(color: Palette.borderColor, width: 1.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info bar for selected key
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: Palette.surfaceColor,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Palette.accentPrimary,
                    borderRadius: BorderRadius.circular(Palette.radiusSmall),
                  ),
                  child: Text(
                    selectedKeyId.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'CURRENT BINDING:',
                  style: TextStyle(
                    color: Palette.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Palette.cardColor,
                    borderRadius: BorderRadius.circular(Palette.radiusSmall),
                    border: Border.all(color: Palette.borderColor, width: 1.0),
                  ),
                  child: Text(
                    currentMapping ?? 'Default Hardware',
                    style: TextStyle(
                      color: currentMapping != null
                          ? Palette.accentBright
                          : Palette.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Physical Keypress Listening Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _lastPressedKeyFeedback != null
                        ? Palette.accentEmerald.withValues(alpha: 0.2)
                        : Palette.accentCyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Palette.radiusSmall),
                    border: Border.all(
                      color: _lastPressedKeyFeedback != null
                          ? Palette.accentEmerald
                          : Palette.accentCyan.withValues(alpha: 0.4),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _lastPressedKeyFeedback != null
                            ? Icons.check_circle_rounded
                            : Icons.keyboard_rounded,
                        size: 14,
                        color: _lastPressedKeyFeedback != null
                            ? Palette.accentEmerald
                            : Palette.accentCyan,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _lastPressedKeyFeedback != null
                            ? 'Pressed: $_lastPressedKeyFeedback'
                            : 'Press any physical key to assign',
                        style: TextStyle(
                          color: _lastPressedKeyFeedback != null
                              ? Palette.accentEmerald
                              : Palette.accentCyan,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (currentMapping != null)
                  TextButton.icon(
                    onPressed: widget.viewModel.resetCurrentKey,
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Palette.accentRose),
                    label: const Text(
                      'Reset to Default',
                      style: TextStyle(color: Palette.accentRose, fontSize: 12.5),
                    ),
                  ),
                IconButton(
                  onPressed: () => widget.viewModel.selectKey(null),
                  tooltip: 'Close remap panel',
                  icon: const Icon(Icons.close_rounded, size: 18, color: Palette.textSecondary),
                ),
              ],
            ),
          ),

          // Categories Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Letters & Numbers'),
              Tab(text: 'Numpad Keys'),
              Tab(text: 'F-Keys & Navigation'),
              Tab(text: 'Modifiers & Media'),
              Tab(text: 'Overload & Custom'),
            ],
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Letters & Numbers & Symbols
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LETTERS',
                        style: TextStyle(
                          color: Palette.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: _letters.map((letter) {
                          return _remapOptionButton(
                            label: letter.toUpperCase(),
                            action: letter,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'NUMBERS',
                        style: TextStyle(
                          color: Palette.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: _numbers.map((digit) {
                          return _remapOptionButton(
                            label: digit,
                            action: digit,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'SYMBOLS & PUNCTUATION',
                        style: TextStyle(
                          color: Palette.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: _symbols.map((item) {
                          return _remapOptionButton(
                            label: item['label']!,
                            action: item['id']!,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // 2. Full Numpad Keys
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FULL NUMPAD CLUSTER (104/108-KEY)',
                        style: TextStyle(
                          color: Palette.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _numpadKeys.map((item) {
                          return _remapOptionButton(
                            label: item['label']!,
                            action: item['id']!,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // 3. F-Keys & Navigation
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FUNCTION KEYS (F1 - F12)',
                        style: TextStyle(
                          color: Palette.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: _functionKeys.map((item) {
                          return _remapOptionButton(
                            label: item['label']!,
                            action: item['id']!,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'NAVIGATION & EDITING',
                        style: TextStyle(
                          color: Palette.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: _navigationKeys.map((item) {
                          return _remapOptionButton(
                            label: item['label']!,
                            action: item['id']!,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // 4. Modifiers & Media
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MODIFIERS & SYSTEM',
                        style: TextStyle(
                          color: Palette.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: _modifiersAndSystem.map((item) {
                          return _remapOptionButton(
                            label: item['label']!,
                            action: item['id']!,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'MEDIA, VOLUME & MOUSE',
                        style: TextStyle(
                          color: Palette.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: _mediaAndMouse.map((item) {
                          return _remapOptionButton(
                            label: item['label']!,
                            action: item['id']!,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // 5. Overload & Custom Macro
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Layer Overload: overload(layer, tap_key)',
                              style: TextStyle(
                                color: Palette.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Hold for target layer, tap for key.',
                              style: TextStyle(
                                color: Palette.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _selectedOverloadLayer,
                                    dropdownColor: Palette.surfaceColor,
                                    style: const TextStyle(
                                      color: Palette.textPrimary,
                                      fontSize: 13,
                                    ),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      labelText: 'Target Layer',
                                    ),
                                    items: layers.map((layer) {
                                      return DropdownMenuItem(
                                        value: layer,
                                        child: Text(layer),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _selectedOverloadLayer = val;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _overloadTapKeyController,
                                    style: const TextStyle(
                                      color: Palette.textPrimary,
                                      fontSize: 13,
                                      fontFamily: 'monospace',
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      hintText: selectedKeyId,
                                      labelText: 'Tap Key',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                final layer = _selectedOverloadLayer ?? 'code';
                                final tapKey = _overloadTapKeyController.text.trim().isEmpty
                                    ? selectedKeyId
                                    : _overloadTapKeyController.text.trim();
                                widget.viewModel.remapCurrentKey('overload($layer, $tapKey)');
                              },
                              child: const Text('APPLY OVERLOAD'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Direct Keyd Syntax or Macro',
                              style: TextStyle(
                                color: Palette.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'e.g. macro(python3), macro(<-), C-tab, noop',
                              style: TextStyle(
                                color: Palette.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _customExpressionController,
                                    style: const TextStyle(
                                      color: Palette.textPrimary,
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                    ),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      hintText: 'e.g. macro(python3) or rightcontrol',
                                    ),
                                    onSubmitted: (text) {
                                      final trimmed = text.trim();
                                      if (trimmed.isNotEmpty) {
                                        widget.viewModel.remapCurrentKey(trimmed);
                                        _customExpressionController.clear();
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    final text = _customExpressionController.text.trim();
                                    if (text.isNotEmpty) {
                                      widget.viewModel.remapCurrentKey(text);
                                      _customExpressionController.clear();
                                    }
                                  },
                                  child: const Text('ASSIGN'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _remapOptionButton({
    required String label,
    required String action,
  }) {
    return InkWell(
      onTap: () => widget.viewModel.remapCurrentKey(action),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
        decoration: BoxDecoration(
          color: Palette.surfaceColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Palette.borderColor, width: 1.0),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Palette.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
