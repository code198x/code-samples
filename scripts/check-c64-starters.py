"""Validate assembled Meet the Machine BASIC starters, including their line chain."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

DEFAULT_ROOT = (
    Path(__file__).resolve().parents[1] / "commodore-64/assembly/meet-the-machine"
)


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def check_program(data: bytes) -> dict[str, int]:
    require(len(data) >= 2, "missing PRG load address")
    load = int.from_bytes(data[:2], "little")
    require(load == 0x0801, "starter must load at BASIC address $0801")
    body = data[2:]
    require(len(body) >= 5, "truncated BASIC line header")
    require(int.from_bytes(body[2:4], "little") == 10, "starter must use BASIC line 10")
    require(body[4] == 0x9E, "starter must begin with the SYS token")
    line_end = body.find(b"\0", 5)
    require(line_end != -1, "missing BASIC line terminator")
    next_line = int.from_bytes(body[:2], "little")
    marker_offset = line_end + 1
    marker_address = load + marker_offset
    require(
        next_line == marker_address,
        f"next-line pointer ${next_line:04x} does not reach end marker ${marker_address:04x}",
    )
    require(
        body[marker_offset : marker_offset + 2] == b"\0\0", "missing BASIC end marker"
    )
    try:
        target = int(body[5:line_end].decode("ascii").strip())
    except (ValueError, UnicodeDecodeError) as error:
        raise ValueError("SYS target must be a decimal address") from error
    code_offset = marker_offset + 2
    code_address = load + code_offset
    require(
        target == code_address, "SYS target does not reach the first machine-code byte"
    )
    require(code_address == 0x080D, "primer machine-code entry moved from $080d")
    require(len(body) > code_offset, "missing machine code after starter")
    return {"load_address": load, "next_line": next_line, "entry": code_address}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=DEFAULT_ROOT)
    args = parser.parse_args()
    sources = sorted(args.root.glob("unit-*/*.asm"))
    if not sources:
        parser.exit(1, f"No primer sources found in {args.root}\n")
    results = []
    errors = []
    for source in sources:
        program = source.with_suffix(".prg")
        try:
            data = program.read_bytes()
            observed = check_program(data)
            results.append(
                {
                    "source": str(source.relative_to(args.root)),
                    "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
                    "program_sha256": hashlib.sha256(data).hexdigest(),
                    **observed,
                }
            )
        except (OSError, ValueError) as error:
            errors.append(
                {"source": str(source.relative_to(args.root)), "error": str(error)}
            )
    print(json.dumps({"checked": results, "errors": errors}, indent=2))
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
