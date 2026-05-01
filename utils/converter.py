"""JSON to string S-expression conversion helpers."""

from __future__ import annotations

import json
import math
import re
from collections.abc import Mapping, Sequence
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
    return isinstance(value, Sequence) and not isinstance(value, (str, bytes, bytearray))


def _key_to_atom(key: Any) -> str:
    key = str(key)
    if _SYMBOL_RE.fullmatch(key) and key not in _RESERVED_ATOMS:
        return key
    return _quote(key)


def _quote(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


__all__ = [
    "SExpression",
    "json_to_s_expression",
    "json_to_sexp",
    "json_to_sexpr",
    "to_s_expression",
]
