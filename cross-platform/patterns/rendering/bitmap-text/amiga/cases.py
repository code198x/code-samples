"""Keep common edge/phase workloads and exercise wide and ignored source pointers."""

from __future__ import annotations

import importlib.util
from pathlib import Path

S = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location(
    "amiga_text_common_cases", S.parent / "cases.py"
)
assert spec and spec.loader
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


def cases(c: dict) -> list[dict]:
    out = C.cases(c)
    for r in out:
        for k in ["font_ptr", "source_ptr"]:
            if r.get(k) == 65535:
                r[k] = 16777215
    extra = [
        {"kind": "string", "xy": [21, 37], "bytes": [], "source_ptr": 16777215},
        {"kind": "string", "xy": [21, 37], "bytes": [65], "source_ptr": 16777216},
        {"kind": "char", "xy": [21, 37], "code": 65, "source_ptr": 4294967295},
        {"kind": "char", "xy": [21, 37], "code": 65, "font_ptr": 16777216},
        {
            "kind": "char",
            "xy": [127, 32],
            "code": 63,
            "font_ptr": 16777208,
            "first": 63,
            "count": 1,
            "fallback": 63,
            "mode": 1,
        },
    ]
    for r in extra:
        r["id"] = f"{len(out):03d}-{r['kind']}"
        out.append(r)
    return out
