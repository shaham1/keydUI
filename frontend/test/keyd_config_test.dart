import 'package:flutter_test/flutter_test.dart';
import 'package:keydui/features/home/model/keyd_config.dart';

void main() {
  group('KeydConfig Tests', () {
    const sampleConfig = '''
[ids]
*

[main]
rightcontrol = backslash
rightalt = escape
capslock = overload(code, capslock)
escape = overload(nums, escape)

[nums]
q = numlock
alt = backspace
space = 0
n = kp1

[code]
* = noop
h = left
j = down
k = up
l = right
''';

    test('Parses INI format correctly', () {
      final config = KeydConfig.parse(sampleConfig);

      expect(config.ids, contains('*'));
      expect(config.layers.containsKey('main'), isTrue);
      expect(config.layers.containsKey('nums'), isTrue);
      expect(config.layers.containsKey('code'), isTrue);

      expect(config.getMapping('main', 'capslock'), 'overload(code, capslock)');
      expect(config.getMapping('main', 'rightalt'), 'escape');
      expect(config.getMapping('nums', 'q'), 'numlock');
      expect(config.getMapping('code', 'h'), 'left');
    });

    test('Modifies key mappings and serializes', () {
      final config = KeydConfig.parse(sampleConfig);
      config.setMapping('main', 'a', 'b');
      expect(config.getMapping('main', 'a'), 'b');

      config.removeMapping('main', 'capslock');
      expect(config.getMapping('main', 'capslock'), isNull);

      final serialized = config.toConfString();
      expect(serialized, contains('[main]'));
      expect(serialized, contains('a = b'));
      expect(serialized, isNot(contains('capslock = overload(code, capslock)')));
    });

    test('Resolves key aliases (comma and ,)', () {
      const configWithAliases = '''
[nums]
, = kp3
alt = backspace
''';
      final config = KeydConfig.parse(configWithAliases);
      expect(config.getMapping('nums', 'comma'), 'kp3');
      expect(config.getMapping('nums', ','), 'kp3');
      expect(config.getMapping('nums', 'leftalt'), 'backspace');
    });
  });
}

