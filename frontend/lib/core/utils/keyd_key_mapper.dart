import 'package:flutter/services.dart';

class KeydKeyMapper {
  /// Maps a Flutter KeyEvent to a valid keyd key name.
  static String? fromKeyEvent(KeyEvent event) {
    final logical = event.logicalKey;

    // Numpad Keys
    if (logical == LogicalKeyboardKey.numpad0) return 'kp0';
    if (logical == LogicalKeyboardKey.numpad1) return 'kp1';
    if (logical == LogicalKeyboardKey.numpad2) return 'kp2';
    if (logical == LogicalKeyboardKey.numpad3) return 'kp3';
    if (logical == LogicalKeyboardKey.numpad4) return 'kp4';
    if (logical == LogicalKeyboardKey.numpad5) return 'kp5';
    if (logical == LogicalKeyboardKey.numpad6) return 'kp6';
    if (logical == LogicalKeyboardKey.numpad7) return 'kp7';
    if (logical == LogicalKeyboardKey.numpad8) return 'kp8';
    if (logical == LogicalKeyboardKey.numpad9) return 'kp9';
    if (logical == LogicalKeyboardKey.numpadDecimal) return 'kpdot';
    if (logical == LogicalKeyboardKey.numpadEnter) return 'kpenter';
    if (logical == LogicalKeyboardKey.numpadAdd) return 'kpplus';
    if (logical == LogicalKeyboardKey.numpadSubtract) return 'kpminus';
    if (logical == LogicalKeyboardKey.numpadMultiply) return 'kpasterisk';
    if (logical == LogicalKeyboardKey.numpadDivide) return 'kpslash';
    if (logical == LogicalKeyboardKey.numpadEqual) return 'kpequal';
    if (logical == LogicalKeyboardKey.numLock) return 'numlock';

    // Letters
    if (logical.keyId >= LogicalKeyboardKey.keyA.keyId &&
        logical.keyId <= LogicalKeyboardKey.keyZ.keyId) {
      final index = logical.keyId - LogicalKeyboardKey.keyA.keyId;
      return String.fromCharCode('a'.codeUnitAt(0) + index);
    }

    // Digits
    if (logical.keyId >= LogicalKeyboardKey.digit0.keyId &&
        logical.keyId <= LogicalKeyboardKey.digit9.keyId) {
      final index = logical.keyId - LogicalKeyboardKey.digit0.keyId;
      return '$index';
    }

    // Function keys F1 - F12
    if (logical == LogicalKeyboardKey.f1) return 'f1';
    if (logical == LogicalKeyboardKey.f2) return 'f2';
    if (logical == LogicalKeyboardKey.f3) return 'f3';
    if (logical == LogicalKeyboardKey.f4) return 'f4';
    if (logical == LogicalKeyboardKey.f5) return 'f5';
    if (logical == LogicalKeyboardKey.f6) return 'f6';
    if (logical == LogicalKeyboardKey.f7) return 'f7';
    if (logical == LogicalKeyboardKey.f8) return 'f8';
    if (logical == LogicalKeyboardKey.f9) return 'f9';
    if (logical == LogicalKeyboardKey.f10) return 'f10';
    if (logical == LogicalKeyboardKey.f11) return 'f11';
    if (logical == LogicalKeyboardKey.f12) return 'f12';

    // Modifiers & System
    if (logical == LogicalKeyboardKey.escape) return 'escape';
    if (logical == LogicalKeyboardKey.tab) return 'tab';
    if (logical == LogicalKeyboardKey.capsLock) return 'capslock';
    if (logical == LogicalKeyboardKey.shiftLeft) return 'leftshift';
    if (logical == LogicalKeyboardKey.shiftRight) return 'rightshift';
    if (logical == LogicalKeyboardKey.controlLeft) return 'leftcontrol';
    if (logical == LogicalKeyboardKey.controlRight) return 'rightcontrol';
    if (logical == LogicalKeyboardKey.altLeft) return 'leftalt';
    if (logical == LogicalKeyboardKey.altRight) return 'rightalt';
    if (logical == LogicalKeyboardKey.metaLeft) return 'leftmeta';
    if (logical == LogicalKeyboardKey.metaRight) return 'rightmeta';
    if (logical == LogicalKeyboardKey.space) return 'space';
    if (logical == LogicalKeyboardKey.backspace) return 'backspace';
    if (logical == LogicalKeyboardKey.enter) return 'enter';

    // Navigation & Editing
    if (logical == LogicalKeyboardKey.arrowUp) return 'up';
    if (logical == LogicalKeyboardKey.arrowDown) return 'down';
    if (logical == LogicalKeyboardKey.arrowLeft) return 'left';
    if (logical == LogicalKeyboardKey.arrowRight) return 'right';
    if (logical == LogicalKeyboardKey.pageUp) return 'pageup';
    if (logical == LogicalKeyboardKey.pageDown) return 'pagedown';
    if (logical == LogicalKeyboardKey.home) return 'home';
    if (logical == LogicalKeyboardKey.end) return 'end';
    if (logical == LogicalKeyboardKey.insert) return 'insert';
    if (logical == LogicalKeyboardKey.delete) return 'delete';
    if (logical == LogicalKeyboardKey.printScreen) return 'print';
    if (logical == LogicalKeyboardKey.scrollLock) return 'scrolllock';
    if (logical == LogicalKeyboardKey.pause) return 'pause';

    // Punctuation & Symbols
    if (logical == LogicalKeyboardKey.minus) return '-';
    if (logical == LogicalKeyboardKey.equal) return '=';
    if (logical == LogicalKeyboardKey.bracketLeft) return '[';
    if (logical == LogicalKeyboardKey.bracketRight) return ']';
    if (logical == LogicalKeyboardKey.backslash) return '\\';
    if (logical == LogicalKeyboardKey.semicolon) return ';';
    if (logical == LogicalKeyboardKey.quote) return '\'';
    if (logical == LogicalKeyboardKey.backquote) return '`';
    if (logical == LogicalKeyboardKey.comma) return ',';
    if (logical == LogicalKeyboardKey.period) return '.';
    if (logical == LogicalKeyboardKey.slash) return '/';

    // Media & Controls
    if (logical == LogicalKeyboardKey.audioVolumeUp) return 'volumeup';
    if (logical == LogicalKeyboardKey.audioVolumeDown) return 'volumedown';
    if (logical == LogicalKeyboardKey.audioVolumeMute) return 'mute';
    if (logical == LogicalKeyboardKey.mediaPlayPause) return 'playpause';
    if (logical == LogicalKeyboardKey.mediaTrackNext) return 'nextsong';
    if (logical == LogicalKeyboardKey.mediaTrackPrevious) return 'previoussong';
    if (logical == LogicalKeyboardKey.mediaStop) return 'stopcd';

    return null;
  }
}

