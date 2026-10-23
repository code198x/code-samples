"""Generate a keyboard loader from the actual emitted Dragon payload."""

from __future__ import annotations

from pathlib import Path


def listing(data: bytes) -> list[str]:
    if not 0 < len(data) < 512:
        raise ValueError("Missing payload or overlap with caller state")
    lines = [
        "CLEAR 200,&H6FFF",
        f"10 FOR I=0 TO {len(data) - 1}:READ A:POKE &H7000+I,A:NEXT",
        "20 END",
    ]
    lines += [
        f"{100 + i} DATA " + ",".join(map(str, data[i : i + 16]))
        for i in range(0, len(data), 16)
    ]
    return lines + ["RUN", "CLS:EXEC &H7000"]


if __name__ == "__main__":
    root = Path(__file__).resolve().parent
    (root / "build/load.bas").write_text(
        "\n".join(listing((root / "build/demo.bin").read_bytes())) + "\n"
    )
