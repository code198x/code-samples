"""Wrap our own assembled bytes in a typed BBC BASIC loader; no firmware."""

from pathlib import Path

r = Path(__file__).resolve().parent
data = (r / "build/demo.bin").read_bytes()
lines = [
    "10 MODE 6",
    "15 HIMEM=&3000",
    '20 PRINT "COLLECT STAR: QAOP / SPACE RESTART"',
    f"30 FOR I%=0 TO {len(data) - 1}:READ B%:I%?&3000=B%:NEXT",
    "40 CALL &3000",
]
for i in range(0, len(data), 16):
    lines.append(
        str(100 + i // 16 * 10) + " DATA " + ",".join(str(x) for x in data[i : i + 16])
    )
(r / "build/loader.bas").write_text("\n".join(lines) + "\n")
