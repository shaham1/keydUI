import unittest
import sys
import os

# Add src to sys.path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))

from keyd_manager.parser import KeydParser
from keyd_manager.validator import ConfigValidator
from keyd_manager.models import KeydProfile


class TestKeydParser(unittest.TestCase):
    SAMPLE_CONF = """# Main keyd configuration
[ids]
*

[main]
capslock = overload(code, capslock)
rightalt = escape

[nums]
q = numlock
space = 0

[code]
* = noop
h = left
i = macro(<-)
\\ = ~
"""

    def test_parse_and_hash(self):
        profile = KeydParser.parse(self.SAMPLE_CONF)
        self.assertEqual(profile.ids, ["*"])
        self.assertIn("main", profile.layers)
        self.assertIn("nums", profile.layers)
        self.assertIn("code", profile.layers)

        self.assertEqual(profile.layers["main"]["capslock"], "overload(code, capslock)")
        self.assertEqual(profile.layers["main"]["rightalt"], "escape")
        self.assertEqual(profile.layers["nums"]["space"], "0")
        self.assertEqual(profile.layers["code"]["*"], "noop")
        self.assertEqual(profile.layers["code"]["\\"], "~")

        # Verify hash is consistent
        expected_hash = KeydParser.calculate_hash(self.SAMPLE_CONF)
        self.assertEqual(profile.content_hash, expected_hash)

    def test_serialization(self):
        profile = KeydParser.parse(self.SAMPLE_CONF)
        serialized = KeydParser.serialize(profile)
        self.assertIn("[ids]\n*", serialized)
        self.assertIn("[main]", serialized)
        self.assertIn("capslock = overload(code, capslock)", serialized)
        self.assertIn("[code]", serialized)

    def test_validator_basic_syntax(self):
        valid_res = ConfigValidator._basic_syntax_check(self.SAMPLE_CONF)
        self.assertTrue(valid_res.is_valid)

        invalid_conf = "bad_line_without_section = 123"
        invalid_res = ConfigValidator._basic_syntax_check(invalid_conf)
        self.assertFalse(invalid_res.is_valid)


if __name__ == "__main__":
    unittest.main()

