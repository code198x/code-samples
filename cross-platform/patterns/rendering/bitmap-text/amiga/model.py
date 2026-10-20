"""Reuse logical glyph semantics; independently pack the selected 40-byte plane."""

from __future__ import annotations

import importlib.util
from pathlib import Path
from types import SimpleNamespace
from typing import Any

S = Path(__file__).resolve().parent


def load(name: str, path: Path) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


BASE = load("amiga_glyph_semantics", S.parent / "model.py")
PLANE = load("amiga_plane_image", S.parents[1] / "remaining-primitives/model.py")
DEFAULT = BASE.DEFAULT
SYNTHETIC = BASE.SYNTHETIC


def packed(c: dict, grid: list[bytearray], padding: int = 0) -> bytes:
    data = bytearray(c["length"])
    for y, row in enumerate(grid):
        for x, bit in enumerate(row):
            if bit:
                data[y * 40 + x // 8] |= 128 >> x % 8
    return bytes(data)


def frame(c: dict, grid: list[bytearray]) -> tuple[tuple[int, int], bytes]:
    return PLANE.frame(c, packed(c, grid))


P = SimpleNamespace(packed=packed, frame=frame)


def evaluate(c: dict, grid: list[bytearray], r: dict) -> dict:
    n = r.get("length", len(r.get("bytes", []))) if r["kind"] == "string" else 1
    valid = (
        0 <= r["font_ptr"] <= 16777215
        and r["font_ptr"] + 8 * r.get("count", 64) <= 16777216
    )
    if r["kind"] == "string":
        valid = (
            valid
            and 0 <= r["source_ptr"] <= 16777215
            and (r["source_ptr"] + n <= 16777216)
        )
    if not valid:
        return {
            "accepted": False,
            "next_x": r["xy"][0],
            "consumed": 0,
            "missing": 0,
            "writes": 0,
            "calls": 0,
        }
    return BASE.evaluate(c, grid, dict(r, font_ptr=0, source_ptr=0))
