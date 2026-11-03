import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keydui/core/utils/keyd_key_mapper.dart';

void main() {
  group('KeydKeyMapper Tests', () {
    test('Maps Numpad keys to kpX correctly', () {
      expect(
        KeydKeyMapper.fromKeyEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.numpad1,
            logicalKey: LogicalKeyboardKey.numpad1,
            timeStamp: Duration.zero,
          ),
        ),
        'kp1',
      );

      expect(
        KeydKeyMapper.fromKeyEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.numpadEnter,
            logicalKey: LogicalKeyboardKey.numpadEnter,
            timeStamp: Duration.zero,
          ),
        ),
        'kpenter',
      );
    });

    test('Maps letters, function keys, and navigation', () {
      expect(
        KeydKeyMapper.fromKeyEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.keyA,
            logicalKey: LogicalKeyboardKey.keyA,
            timeStamp: Duration.zero,
          ),
        ),
        'a',
      );

      expect(
        KeydKeyMapper.fromKeyEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.f5,
            logicalKey: LogicalKeyboardKey.f5,
            timeStamp: Duration.zero,
          ),
        ),
        'f5',
      );

      expect(
        KeydKeyMapper.fromKeyEvent(
          const KeyDownEvent(
            physicalKey: PhysicalKeyboardKey.arrowDown,
            logicalKey: LogicalKeyboardKey.arrowDown,
            timeStamp: Duration.zero,
          ),
        ),
        'down',
      );
    });
  });
}

