import math
import unittest

from utils.converter import (
    json_to_s_expression,
    json_to_sexp,
    json_to_sexpr,
    to_s_expression,
)


class JsonToSExpressionTests(unittest.TestCase):
    def test_empty_dict(self):
        self.assertEqual(json_to_s_expression({}), "()")

    def test_empty_list(self):
        self.assertEqual(json_to_s_expression([]), "()")

    def test_flat_dictionary(self):
        self.assertEqual(
            json_to_s_expression({"name": "Ada", "age": 36}),
            '((name "Ada") (age 36))',
        )

    def test_dictionary_preserves_insertion_order(self):
        self.assertEqual(
            json_to_s_expression({"z": 1, "a": 2, "middle": 3}),
            "((z 1) (a 2) (middle 3))",
        )

    def test_nested_dictionary(self):
        self.assertEqual(
            json_to_s_expression({"outer": {"inner": {"value": 7}}}),
            "((outer ((inner ((value 7))))))",
        )

    def test_list_of_scalars(self):
        self.assertEqual(
            json_to_s_expression([1, "two", True, None]),
            '(1 "two" true nil)',
        )

    def test_nested_list(self):
        self.assertEqual(
            json_to_s_expression([1, [2, [3, []]]]),
            "(1 (2 (3 ())))",
        )

    def test_list_of_dictionaries(self):
        self.assertEqual(
            json_to_s_expression([{"id": 1}, {"id": 2, "active": False}]),
            "(((id 1)) ((id 2) (active false)))",
        )

    def test_dictionary_with_list_value(self):
        self.assertEqual(
            json_to_s_expression({"numbers": [1, 2, 3]}),
            "((numbers (1 2 3)))",
        )

    def test_dictionary_with_nested_mixed_values(self):
        self.assertEqual(
            json_to_s_expression(
                {
                    "agent": {
                        "name": "qwestor",
                        "goals": [
                            {"name": "eat", "priority": 0.7},
                            {"name": "sleep", "priority": 0.3},
                        ],
                    },
                    "enabled": True,
                }
            ),
            (
                '((agent ((name "qwestor") '
                '(goals (((name "eat") (priority 0.7)) '
                '((name "sleep") (priority 0.3)))))) '
                "(enabled true))"
            ),
        )

    def test_string_scalar(self):
        self.assertEqual(json_to_s_expression("hello"), '"hello"')

    def test_quoted_json_string_scalar(self):
        self.assertEqual(json_to_s_expression('"hello"'), '"hello"')

    def test_string_escaping(self):
        self.assertEqual(
            json_to_s_expression('hello "world"\nnext'),
            '"hello \\"world\\"\\nnext"',
        )

    def test_integer_scalar(self):
        self.assertEqual(json_to_s_expression(42), "42")

    def test_float_scalar(self):
        self.assertEqual(json_to_s_expression(3.14), "3.14")

    def test_boolean_scalars(self):
        self.assertEqual(json_to_s_expression(True), "true")
        self.assertEqual(json_to_s_expression(False), "false")

    def test_none_scalar(self):
        self.assertEqual(json_to_s_expression(None), "nil")

    def test_json_object_string(self):
        self.assertEqual(
            json_to_s_expression('{"a": [1, {"b": false}], "c": null}'),
            "((a (1 ((b false)))) (c nil))",
        )

    def test_json_array_string(self):
        self.assertEqual(
            json_to_s_expression('[{"a": 1}, {"b": [true, null]}]'),
            "(((a 1)) ((b (true nil))))",
        )

    def test_json_primitive_strings(self):
        self.assertEqual(json_to_s_expression("123"), "123")
        self.assertEqual(json_to_s_expression("-4.5"), "-4.5")
        self.assertEqual(json_to_s_expression("true"), "true")
        self.assertEqual(json_to_s_expression("false"), "false")
        self.assertEqual(json_to_s_expression("null"), "nil")

    def test_json_string_with_surrounding_whitespace(self):
        self.assertEqual(json_to_s_expression('  {"ok": true}  '), "((ok true))")
        self.assertEqual(json_to_s_expression("  true  "), "true")

    def test_plain_string_that_starts_like_json_keyword_is_not_decoded(self):
        self.assertEqual(json_to_s_expression("true-ish"), '"true-ish"')
        self.assertEqual(json_to_s_expression("null-value"), '"null-value"')
        self.assertEqual(json_to_s_expression("123abc"), '"123abc"')

    def test_dictionary_keys_are_converted_to_string_atoms_or_strings(self):
        self.assertEqual(
            json_to_s_expression({1: "one", 2.5: "float", None: "nothing", False: "no"}),
            '(("1" "one") ("2.5" "float") (None "nothing") (False "no"))',
        )

    def test_dictionary_keys_with_spaces_are_quoted(self):
        self.assertEqual(
            json_to_s_expression({"first name": "Ada", "last-name": "Lovelace"}),
            '(("first name" "Ada") (last-name "Lovelace"))',
        )

    def test_dictionary_keys_matching_reserved_atoms_are_quoted(self):
        self.assertEqual(
            json_to_s_expression({"true": 1, "false": 2, "nil": 3}),
            '(("true" 1) ("false" 2) ("nil" 3))',
        )

    def test_tuple_input_is_treated_like_array_input(self):
        self.assertEqual(json_to_s_expression((1, {"a": 2})), "(1 ((a 2)))")

    def test_aliases_return_same_result(self):
        value = {"x": [1, {"y": None}]}
        expected = "((x (1 ((y nil)))))"
        self.assertEqual(json_to_sexp(value), expected)
        self.assertEqual(json_to_sexpr(value), expected)
        self.assertEqual(to_s_expression(value), expected)

    def test_return_type_is_string_for_every_supported_shape(self):
        values = [
            {},
            [],
            {"a": [1, {"b": False}]},
            [1, 2, 3],
            "hello",
            1,
            1.5,
            True,
            None,
        ]

        for value in values:
            with self.subTest(value=value):
                self.assertIsInstance(json_to_s_expression(value), str)

    def test_non_finite_float_raises_value_error(self):
        for value in (math.inf, -math.inf, math.nan):
            with self.subTest(value=value):
                with self.assertRaises(ValueError):
                    json_to_s_expression(value)

    def test_unsupported_bytes_raise_type_error(self):
        with self.assertRaises(TypeError):
            json_to_s_expression(b"bytes")

    def test_unsupported_object_raises_type_error(self):
        with self.assertRaises(TypeError):
            json_to_s_expression(object())

    def test_invalid_json_like_string_raises_json_decode_error(self):
        with self.assertRaises(ValueError):
            json_to_s_expression("{not valid json}")


if __name__ == "__main__":
    unittest.main()
