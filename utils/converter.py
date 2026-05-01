"""JSON and string S-expression conversion helpers."""

from __future__ import annotations

import json
import math
import re
from collections.abc import Mapping, Sequence
from pathlib import Path
from typing import Any

_SYMBOL_RE = re.compile(r"^[A-Za-z_+\-*/<>=!?$%&~^][A-Za-z0-9_+\-*/<>=!?$%&~^.:#@-]*$")
_JSON_NUMBER_RE = re.compile(r"^-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?\s*$")
_RESERVED_ATOMS = {"true", "false", "nil"}

SExpression = str


def json_to_s_expression(value: Any) -> SExpression:
    """Convert a JSON document or decoded JSON value to a string S-expression.

    Dictionaries are represented as lists of key/value pairs:

        {"name": "Ada", "scores": [1, 2]} -> ((name "Ada") (scores (1 2)))

    Strings that look like JSON documents are decoded first, so both a JSON
    string and an already-decoded Python dict/list/scalar are accepted.
    """

    return _to_s_expression(_decode_if_json_document(value))


def json_to_sexp(value: Any) -> SExpression:
    """Alias for json_to_s_expression."""

    return json_to_s_expression(value)


def json_to_sexpr(value: Any) -> SExpression:
    """Alias for json_to_s_expression."""

    return json_to_s_expression(value)


def to_s_expression(value: Any) -> SExpression:
    """Alias for json_to_s_expression."""

    return json_to_s_expression(value)


def read_json_file(path: Any, *, encoding: str = "utf-8") -> Any:
    """Read a JSON file and return its decoded Python value."""

    with Path(path).open("r", encoding=encoding) as json_file:
        return json.load(json_file)


def json_file_to_s_expression(path: Any, *, encoding: str = "utf-8") -> SExpression:
    """Read a JSON file and convert its decoded value to a string S-expression."""

    return json_to_s_expression(read_json_file(path, encoding=encoding))


def json_file_to_sexp(path: Any, *, encoding: str = "utf-8") -> SExpression:
    """Alias for json_file_to_s_expression."""

    return json_file_to_s_expression(path, encoding=encoding)


def json_file_to_sexpr(path: Any, *, encoding: str = "utf-8") -> SExpression:
    """Alias for json_file_to_s_expression."""

    return json_file_to_s_expression(path, encoding=encoding)


def file_to_s_expression(path: Any, *, encoding: str = "utf-8") -> SExpression:
    """Alias for json_file_to_s_expression."""

    return json_file_to_s_expression(path, encoding=encoding)


def s_expression_to_json(value: SExpression, *, empty_object: bool = False) -> str:
    """Convert a string S-expression to a compact JSON document string."""

    return json.dumps(
        s_expression_to_json_value(value, empty_object=empty_object),
        ensure_ascii=False,
        separators=(",", ":"),
    )


def s_expression_to_json_value(
    value: SExpression, *, empty_object: bool = False
) -> Any:
    """Convert a string S-expression to a decoded JSON-compatible Python value.

    Non-empty lists whose elements are all key/value pairs are treated as JSON
    objects. Empty S-expressions are decoded as arrays by default because the
    string form ``()`` cannot distinguish an empty object from an empty array.
    Set ``empty_object=True`` to decode ``()`` as ``{}``.
    """

    return _s_expression_node_to_json_value(
        _SExpressionParser(value).parse(),
        empty_object=empty_object,
    )


def sexp_to_json(value: SExpression, *, empty_object: bool = False) -> str:
    """Alias for s_expression_to_json."""

    return s_expression_to_json(value, empty_object=empty_object)


def sexpr_to_json(value: SExpression, *, empty_object: bool = False) -> str:
    """Alias for s_expression_to_json."""

    return s_expression_to_json(value, empty_object=empty_object)


def to_json(value: SExpression, *, empty_object: bool = False) -> str:
    """Alias for s_expression_to_json."""

    return s_expression_to_json(value, empty_object=empty_object)


def _decode_if_json_document(value: Any) -> Any:
    if not isinstance(value, str):
        return value

    stripped = value.strip()
    if not stripped:
        return value

    if (
        stripped[0] in '{["'
        or stripped in {"true", "false", "null"}
        or _JSON_NUMBER_RE.fullmatch(stripped)
    ):
        return json.loads(value)

    return value


def _to_s_expression(value: Any) -> SExpression:
    if isinstance(value, Mapping):
        pairs = (
            f"({_key_to_atom(key)} {_to_s_expression(item)})"
            for key, item in value.items()
        )
        return f"({' '.join(pairs)})"

    if _is_json_array(value):
        return f"({' '.join(_to_s_expression(item) for item in value)})"

    if isinstance(value, str):
        return _quote(value)

    if isinstance(value, bool):
        return "true" if value else "false"

    if value is None:
        return "nil"

    if isinstance(value, int):
        return str(value)

    if isinstance(value, float):
        if not math.isfinite(value):
            raise ValueError("JSON numbers must be finite")
        return repr(value)

    raise TypeError(f"Unsupported JSON value: {value!r}")


def _is_json_array(value: Any) -> bool:
    return isinstance(value, Sequence) and not isinstance(
        value, (str, bytes, bytearray)
    )


def _key_to_atom(key: Any) -> str:
    key = str(key)
    if _SYMBOL_RE.fullmatch(key) and key not in _RESERVED_ATOMS:
        return key
    return _quote(key)


def _quote(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


class _Atom(str):
    pass


class _QuotedString(str):
    pass


class _SExpressionParser:
    def __init__(self, text: SExpression):
        if not isinstance(text, str):
            raise TypeError("S-expression value must be a string")

        self.text = text
        self.index = 0
        self.decoder = json.JSONDecoder()

    def parse(self) -> Any:
        value = self._parse_value()
        self._skip_whitespace()
        if self.index != len(self.text):
            raise ValueError(f"Unexpected token at position {self.index}")
        return value

    def _parse_value(self) -> Any:
        self._skip_whitespace()
        if self.index >= len(self.text):
            raise ValueError("Unexpected end of S-expression")

        char = self.text[self.index]
        if char == "(":
            return self._parse_list()
        if char == ")":
            raise ValueError(f"Unexpected ')' at position {self.index}")
        if char == '"':
            return self._parse_quoted_string()
        return self._parse_atom()

    def _parse_list(self) -> list[Any]:
        self.index += 1
        items = []

        while True:
            self._skip_whitespace()
            if self.index >= len(self.text):
                raise ValueError("Unclosed S-expression list")
            if self.text[self.index] == ")":
                self.index += 1
                return items
            items.append(self._parse_value())

    def _parse_quoted_string(self) -> _QuotedString:
        try:
            value, end = self.decoder.raw_decode(self.text, self.index)
        except json.JSONDecodeError as error:
            raise ValueError(
                f"Invalid quoted string at position {self.index}"
            ) from error

        if not isinstance(value, str):
            raise ValueError(f"Expected quoted string at position {self.index}")

        self.index = end
        return _QuotedString(value)

    def _parse_atom(self) -> _Atom:
        start = self.index
        while (
            self.index < len(self.text)
            and not self.text[self.index].isspace()
            and self.text[self.index] not in "()"
        ):
            self.index += 1

        if start == self.index:
            raise ValueError(f"Expected atom at position {self.index}")
        return _Atom(self.text[start : self.index])

    def _skip_whitespace(self) -> None:
        while self.index < len(self.text) and self.text[self.index].isspace():
            self.index += 1


def _s_expression_node_to_json_value(node: Any, *, empty_object: bool) -> Any:
    if isinstance(node, list):
        if not node:
            return {} if empty_object else []
        if _is_object_node(node):
            return {
                str(key): _s_expression_node_to_json_value(
                    value, empty_object=empty_object
                )
                for key, value in node
            }
        return [
            _s_expression_node_to_json_value(item, empty_object=empty_object)
            for item in node
        ]

    if isinstance(node, _QuotedString):
        return str(node)

    if isinstance(node, _Atom):
        return _atom_to_json_value(node)

    raise TypeError(f"Unsupported S-expression node: {node!r}")


def _is_object_node(node: list[Any]) -> bool:
    return all(
        isinstance(item, list) and len(item) == 2 and _is_object_key_node(item[0])
        for item in node
    )


def _is_object_key_node(node: Any) -> bool:
    if isinstance(node, _Atom):
        return bool(_SYMBOL_RE.fullmatch(str(node))) and node not in _RESERVED_ATOMS

    if isinstance(node, _QuotedString):
        value = str(node)
        return not (_SYMBOL_RE.fullmatch(value) and value not in _RESERVED_ATOMS)

    return False


def _atom_to_json_value(atom: _Atom) -> Any:
    value = str(atom)
    if value == "true":
        return True
    if value == "false":
        return False
    if value in {"nil", "null"}:
        return None
    if _JSON_NUMBER_RE.fullmatch(value):
        if any(char in value for char in ".eE"):
            return float(value)
        return int(value)
    return value


__all__ = [
    "SExpression",
    "file_to_s_expression",
    "json_file_to_s_expression",
    "json_file_to_sexp",
    "json_file_to_sexpr",
    "json_to_s_expression",
    "json_to_sexp",
    "json_to_sexpr",
    "read_json_file",
    "s_expression_to_json",
    "s_expression_to_json_value",
    "sexp_to_json",
    "sexpr_to_json",
    "to_s_expression",
    "to_json",
]
