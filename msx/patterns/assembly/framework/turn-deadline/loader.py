"""Generate the MSX BASIC READ/POKE/USR loader from emitted bytes."""

from __future__ import annotations

from pathlib import Path


def listing(data: bytes) -> list[str]:
    if not 0 < len(data) < 700:
        raise ValueError("Payload outside loader reservation")
    lines = [
        "CLEAR 200,49151",
        f"10 FOR I=0 TO {len(data) - 1}:READ A:POKE 49152+I,A:NEXT I",
        "20 DEF USR=49152",
        "30 END",
    ]
    lines += [
        f"{100 + i} DATA " + ",".join(map(str, data[i : i + 12]))
        for i in range(0, len(data), 12)
    ]
    return lines + ["RUN", "SCREEN 0:WIDTH 40:CLS:A=USR(0)"]


if __name__ == "__main__":
    root = Path(__file__).resolve().parent
    (root / "build/load.bas").write_text(
        "\n".join(listing((root / "build/demo.bin").read_bytes())) + "\n"
    )
