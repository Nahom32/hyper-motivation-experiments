import json
import math
import tempfile
import unittest
from pathlib import Path

from utils.converter import (
    file_to_s_expression,
    json_file_to_s_expression,
    json_file_to_sexp,
    json_file_to_sexpr,
    json_to_s_expression,
    json_to_sexp,
    json_to_sexpr,
    read_json_file,
    s_expression_to_json,
    s_expression_to_json_value,
    sexp_to_json,
    sexpr_to_json,
    to_s_expression,
    to_json,
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
            json_to_s_expression(
                {1: "one", 2.5: "float", None: "nothing", False: "no"}
            ),
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


class JsonFileReaderTests(unittest.TestCase):
    fixture_path = (
        Path(__file__).resolve().parents[1] / "utils" / "dummy_json_samples.json"
    )

    def test_read_json_file_from_path_object(self):
        value = read_json_file(self.fixture_path)

        self.assertEqual(value["user"]["name"], "Ada Lovelace")
        self.assertEqual(value["tasks"][0]["id"], "task-001")
        self.assertIsNone(value["metadata"]["notes"])

    def test_read_json_file_from_string_path(self):
        value = read_json_file(str(self.fixture_path))

        self.assertEqual(value["metadata"]["source"], "dummy-fixture")
        self.assertEqual(value["user"]["roles"], ["admin", "researcher"])

    def test_json_file_to_s_expression_matches_decoded_conversion(self):
        decoded = read_json_file(self.fixture_path)

        self.assertEqual(
            json_file_to_s_expression(self.fixture_path),
            json_to_s_expression(decoded),
        )

    def test_json_file_to_s_expression_contains_nested_values(self):
        sexpr = json_file_to_s_expression(self.fixture_path)

        self.assertIn('(name "Ada Lovelace")', sexpr)
        self.assertIn('(roles ("admin" "researcher"))', sexpr)
        self.assertIn("(notes nil)", sexpr)

    def test_json_file_reader_aliases_return_same_result(self):
        expected = json_file_to_s_expression(self.fixture_path)

        self.assertEqual(json_file_to_sexp(self.fixture_path), expected)
        self.assertEqual(json_file_to_sexpr(self.fixture_path), expected)
        self.assertEqual(file_to_s_expression(self.fixture_path), expected)

    def test_read_json_file_missing_path_raises_file_not_found_error(self):
        with self.assertRaises(FileNotFoundError):
            read_json_file(self.fixture_path.with_name("missing.json"))

    def test_read_json_file_invalid_json_raises_json_decode_error(self):
        with tempfile.TemporaryDirectory() as directory:
            invalid_path = Path(directory) / "invalid.json"
            invalid_path.write_text("{not valid json}", encoding="utf-8")

            with self.assertRaises(json.JSONDecodeError):
                read_json_file(invalid_path)


class SExpressionToJsonTests(unittest.TestCase):
    def test_flat_object_to_json_string(self):
        self.assertEqual(
            s_expression_to_json('((name "Ada") (age 36))'),
            '{"name":"Ada","age":36}',
        )

    def test_flat_object_to_json_value(self):
        self.assertEqual(
            s_expression_to_json_value('((name "Ada") (age 36))'),
            {"name": "Ada", "age": 36},
        )

    def test_nested_object_to_json_value(self):
        self.assertEqual(
            s_expression_to_json_value("((outer ((inner ((value 7))))))"),
            {"outer": {"inner": {"value": 7}}},
        )

    def test_list_of_scalars_to_json_string(self):
        self.assertEqual(
            s_expression_to_json('(1 "two" true nil)'),
            '[1,"two",true,null]',
        )

    def test_nested_list_to_json_value(self):
        self.assertEqual(
            s_expression_to_json_value("(1 (2 (3 ())))"),
            [1, [2, [3, []]]],
        )

    def test_list_of_objects_to_json_value(self):
        self.assertEqual(
            s_expression_to_json_value("(((id 1)) ((id 2) (active false)))"),
            [{"id": 1}, {"id": 2, "active": False}],
        )

    def test_nested_mixed_s_expression_to_json_value(self):
        self.assertEqual(
            s_expression_to_json_value(
                '((agent ((name "qwestor") '
                '(goals (((name "eat") (priority 0.7)) '
                '((name "sleep") (priority 0.3)))))) '
                "(enabled true))"
            ),
            {
                "agent": {
                    "name": "qwestor",
                    "goals": [
                        {"name": "eat", "priority": 0.7},
                        {"name": "sleep", "priority": 0.3},
                    ],
                },
                "enabled": True,
            },
        )

    def test_quoted_string_scalar_to_json_string(self):
        self.assertEqual(s_expression_to_json('"hello"'), '"hello"')

    def test_escaped_quoted_string_to_json_value(self):
        self.assertEqual(
            s_expression_to_json_value('"hello \\"world\\"\\nnext"'),
            'hello "world"\nnext',
        )

    def test_unquoted_atom_value_to_json_string(self):
        self.assertEqual(s_expression_to_json("hello"), '"hello"')

    def test_number_values_to_json(self):
        self.assertEqual(s_expression_to_json("42"), "42")
        self.assertEqual(s_expression_to_json("-4.5"), "-4.5")
        self.assertEqual(s_expression_to_json("1e3"), "1000.0")

    def test_boolean_and_null_values_to_json(self):
        self.assertEqual(s_expression_to_json("true"), "true")
        self.assertEqual(s_expression_to_json("false"), "false")
        self.assertEqual(s_expression_to_json("nil"), "null")
        self.assertEqual(s_expression_to_json("null"), "null")

    def test_empty_s_expression_defaults_to_array(self):
        self.assertEqual(s_expression_to_json("()"), "[]")
        self.assertEqual(s_expression_to_json_value("()"), [])

    def test_empty_s_expression_can_be_forced_to_object(self):
        self.assertEqual(s_expression_to_json("()", empty_object=True), "{}")
        self.assertEqual(s_expression_to_json_value("()", empty_object=True), {})

    def test_quoted_object_keys(self):
        self.assertEqual(
            s_expression_to_json_value(
                '(("first name" "Ada") ("true" 1) (False "no"))'
            ),
            {"first name": "Ada", "true": 1, "False": "no"},
        )

    def test_array_of_pairs_with_quoted_symbol_key_remains_array(self):
        self.assertEqual(s_expression_to_json_value('(("a" 1))'), [["a", 1]])

    def test_array_of_numeric_pairs_remains_array(self):
        self.assertEqual(s_expression_to_json_value("((1 2))"), [[1, 2]])

    def test_aliases_return_same_json_string(self):
        value = "((x (1 ((y nil)))))"
        expected = '{"x":[1,{"y":null}]}'
        self.assertEqual(sexp_to_json(value), expected)
        self.assertEqual(sexpr_to_json(value), expected)
        self.assertEqual(to_json(value), expected)

    def test_round_trip_common_json_shapes(self):
        values = [
            {"name": "Ada", "scores": [1, 2, {"ok": True}]},
            [{"id": 1}, {"id": 2, "active": False}],
            [1, ["two", None], {"three": 3.0}],
            "hello",
            42,
            False,
            None,
        ]

        for value in values:
            with self.subTest(value=value):
                sexpr = json_to_s_expression(value)
                self.assertEqual(json.loads(s_expression_to_json(sexpr)), value)

    def test_extra_tokens_raise_value_error(self):
        with self.assertRaises(ValueError):
            s_expression_to_json('((name "Ada")) trailing')

    def test_unclosed_list_raises_value_error(self):
        with self.assertRaises(ValueError):
            s_expression_to_json('((name "Ada")')

    def test_unexpected_close_paren_raises_value_error(self):
        with self.assertRaises(ValueError):
            s_expression_to_json(")")

    def test_invalid_quoted_string_raises_value_error(self):
        with self.assertRaises(ValueError):
            s_expression_to_json('"unterminated')


if __name__ == "__main__":
    unittest.main()
