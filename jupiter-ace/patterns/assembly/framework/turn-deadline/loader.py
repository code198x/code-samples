"""Produce a stock FORTH keyboard loader from the emitted Ace image."""

from __future__ import annotations

from pathlib import Path


def listing(data: bytes) -> list[str]:
    if not 0 < len(data) < 600:
        raise ValueError("Image exceeds this stock-memory loader budget")
    lines = [
        "DECIMAL",
        ": TURNS 15616 CALL ;",
        ": RESERVE HERE 15616 > IF ABORT THEN 15616 HERE - ALLOT ;",
        "RESERVE",
    ]
    lines += [
        " ".join(f"{v} C," for v in data[i : i + 8]) for i in range(0, len(data), 8)
    ]
    return lines + ["CLS TURNS"]


if __name__ == "__main__":
    root = Path(__file__).resolve().parent
    (root / "build/load.fth").write_text(
        "\n".join(listing((root / "build/demo.bin").read_bytes())) + "\n"
    )
