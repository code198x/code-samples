"""Package original probes for the stock MTX BASIC and Einstein MOS loaders."""

from __future__ import annotations

import argparse
from pathlib import Path


def basic_loader(data: bytes) -> str:
    if not data or len(data) > 0x1000:
        raise ValueError("MTX caller must fit in $E000-$EFFF")
    lines = [
        f"10 FOR A=57344 TO {57343 + len(data)}",
        "20 READ B:POKE A,B:NEXT A",
        "30 LET X=USR(57344)",
    ]
    lines.extend(
        f"{100 + offset} DATA " + ",".join(map(str, data[offset : offset + 12]))
        for offset in range(0, len(data), 12)
    )
    return "\n".join(lines) + "\n"


def einstein_disk(data: bytes) -> bytes:
    if len(data) != 512:
        raise ValueError("MOS caller must contain its header and one 512-byte sector")
    if data[:7] != bytes([0, 0x90, 0, 0x92, 7, 0x90, 0]):
        raise ValueError("Expected MOS destination/end/entry/mode header")
    dsk = bytearray(256 + 256 + 10 * 512)
    dsk[:23] = b"EXTENDED CPC DSK File\r\n"
    dsk[0x30:0x32] = bytes([1, 1])
    dsk[0x34] = 21
    dsk[0x100:0x10C] = b"Track-Info\r\n"
    dsk[0x114:0x116] = bytes([2, 10])
    for sector in range(10):
        descriptor = 0x118 + 8 * sector
        dsk[descriptor + 2] = sector
        dsk[descriptor + 3] = 2
        dsk[descriptor + 7] = 2
    dsk[0x200:0x400] = data
    return bytes(dsk)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--system", choices=["memotech-mtx", "tatung-einstein"], required=True
    )
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    data = args.binary.read_bytes()
    if args.system == "memotech-mtx":
        args.output.write_text(basic_loader(data))
    else:
        args.output.write_bytes(einstein_disk(data))


if __name__ == "__main__":
    main()
