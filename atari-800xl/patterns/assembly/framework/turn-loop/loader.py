"""Generate a stock Atari BASIC page-six loader for the original caller."""

from pathlib import Path

r = Path(__file__).resolve().parent
data = (r / "build/demo.bin").read_bytes()
assert len(data) <= 224, "Code would overlap page-six context"
lines = [
    '10 GRAPHICS 0:POSITION 0,0:PRINT "TURN 00"',
    f"20 FOR I=0 TO {len(data) - 1}:READ B:POKE 1536+I,B:NEXT I",
    "30 X=USR(1536)",
]
for i in range(0, len(data), 12):
    lines.append(
        str(100 + i // 12 * 10) + " DATA " + ",".join(str(b) for b in data[i : i + 12])
    )
(r / "build/loader.bas").write_text("\n".join(lines) + "\n")
