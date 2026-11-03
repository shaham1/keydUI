import 'package:keydui/features/home/model/key_definition.dart';

class KeyboardLayout {
  static const List<List<KeyDefinition>> standardAnsi = [
    // Row 0: Numbers & Esc
    [
      KeyDefinition(id: 'escape', label: 'ESC', flex: 1.0, isModifier: true),
      KeyDefinition(id: '1', label: '1', shiftLabel: '!'),
      KeyDefinition(id: '2', label: '2', shiftLabel: '@'),
      KeyDefinition(id: '3', label: '3', shiftLabel: '#'),
      KeyDefinition(id: '4', label: '4', shiftLabel: '\$'),
      KeyDefinition(id: '5', label: '5', shiftLabel: '%'),
      KeyDefinition(id: '6', label: '6', shiftLabel: '^'),
      KeyDefinition(id: '7', label: '7', shiftLabel: '&'),
      KeyDefinition(id: '8', label: '8', shiftLabel: '*'),
      KeyDefinition(id: '9', label: '9', shiftLabel: '('),
      KeyDefinition(id: '0', label: '0', shiftLabel: ')'),
      KeyDefinition(id: 'minus', label: '-', shiftLabel: '_'),
      KeyDefinition(id: 'equal', label: '=', shiftLabel: '+'),
      KeyDefinition(id: 'backspace', label: 'BACKSPACE', flex: 2.0, isModifier: true),
    ],

    // Row 1: QWERTY
    [
      KeyDefinition(id: 'tab', label: 'TAB', flex: 1.5, isModifier: true),
      KeyDefinition(id: 'q', label: 'Q'),
      KeyDefinition(id: 'w', label: 'W'),
      KeyDefinition(id: 'e', label: 'E'),
      KeyDefinition(id: 'r', label: 'R'),
      KeyDefinition(id: 't', label: 'T'),
      KeyDefinition(id: 'y', label: 'Y'),
      KeyDefinition(id: 'u', label: 'U'),
      KeyDefinition(id: 'i', label: 'I'),
      KeyDefinition(id: 'o', label: 'O'),
      KeyDefinition(id: 'p', label: 'P'),
      KeyDefinition(id: 'leftbrace', label: '[', shiftLabel: '{'),
      KeyDefinition(id: 'rightbrace', label: ']', shiftLabel: '}'),
      KeyDefinition(id: 'backslash', label: '\\', shiftLabel: '|', flex: 1.5),
    ],

    // Row 2: ASDF
    [
      KeyDefinition(id: 'capslock', label: 'CAPS', flex: 1.75, isModifier: true),
      KeyDefinition(id: 'a', label: 'A'),
      KeyDefinition(id: 's', label: 'S'),
      KeyDefinition(id: 'd', label: 'D'),
      KeyDefinition(id: 'f', label: 'F'),
      KeyDefinition(id: 'g', label: 'G'),
      KeyDefinition(id: 'h', label: 'H'),
      KeyDefinition(id: 'j', label: 'J'),
      KeyDefinition(id: 'k', label: 'K'),
      KeyDefinition(id: 'l', label: 'L'),
      KeyDefinition(id: 'semicolon', label: ';', shiftLabel: ':'),
      KeyDefinition(id: 'apostrophe', label: '\'', shiftLabel: '"'),
      KeyDefinition(id: 'enter', label: 'ENTER', flex: 2.25, isModifier: true),
    ],

    // Row 3: ZXCV & Up Arrow
    [
      KeyDefinition(id: 'leftshift', label: 'SHIFT', flex: 2.25, isModifier: true),
      KeyDefinition(id: 'z', label: 'Z'),
      KeyDefinition(id: 'x', label: 'X'),
      KeyDefinition(id: 'c', label: 'C'),
      KeyDefinition(id: 'v', label: 'V'),
      KeyDefinition(id: 'b', label: 'B'),
      KeyDefinition(id: 'n', label: 'N'),
      KeyDefinition(id: 'm', label: 'M'),
      KeyDefinition(id: 'comma', label: ',', shiftLabel: '<'),
      KeyDefinition(id: 'dot', label: '.', shiftLabel: '>'),
      KeyDefinition(id: 'slash', label: '/', shiftLabel: '?'),
      KeyDefinition(id: 'rightshift', label: 'SHIFT', flex: 1.75, isModifier: true),
      KeyDefinition(id: 'up', label: '▲', flex: 1.0, isModifier: true),
    ],

    // Row 4: Space & Navigation
    [
      KeyDefinition(id: 'leftcontrol', label: 'CTRL', flex: 1.25, isModifier: true),
      KeyDefinition(id: 'leftmeta', label: 'META', flex: 1.25, isModifier: true),
      KeyDefinition(id: 'leftalt', label: 'ALT', flex: 1.25, isModifier: true),
      KeyDefinition(id: 'space', label: 'SPACE', flex: 6.25),
      KeyDefinition(id: 'rightalt', label: 'ALT', flex: 1.25, isModifier: true),
      KeyDefinition(id: 'rightcontrol', label: 'CTRL', flex: 1.25, isModifier: true),
      KeyDefinition(id: 'left', label: '◀', flex: 1.0, isModifier: true),
      KeyDefinition(id: 'down', label: '▼', flex: 1.0, isModifier: true),
      KeyDefinition(id: 'right', label: '▶', flex: 1.0, isModifier: true),
    ],
  ];
}

