"""Generate an Atari BASIC keyboard loader with an explicit high-RAM reservation."""

from __future__ import annotations

from pathlib import Path


def listing(data: bytes) -> list[str]:
    if not 0 < len(data) < 768:
        raise ValueError("Payload overlaps caller-owned state")
    lines = [
        "5 POKE 106,124:GRAPHICS 0",
        f"10 FOR I=0 TO {len(data) - 1}:READ B:POKE 32768+I,B:NEXT I",
        "20 END",
    ]
    lines += [
        f"{100 + i // 12 * 10} DATA " + ",".join(map(str, data[i : i + 12]))
        for i in range(0, len(data), 12)
    ]
    return lines + ["RUN", "X=USR(32768)"]


if __name__ == "__main__":
    root = Path(__file__).resolve().parent
    (root / "build/load.bas").write_text(
        "\n".join(listing((root / "build/demo.bin").read_bytes())) + "\n"
    )
