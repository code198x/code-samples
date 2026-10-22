"""Generate a CPC BASIC loader with RAM reserved above HIMEM."""

from pathlib import Path

r = Path(__file__).resolve().parent
data = (r / "build/demo.bin").read_bytes()
lines = [
    "10 MEMORY &8FEF:MODE 1:POKE &8FF4,165:POKE &8FF5,90",
    f"20 FOR I=0 TO {len(data) - 1}:READ B:POKE &9000+I,B:NEXT",
    "30 CALL &9000",
]
for i in range(0, len(data), 16):
    lines.append(
        str(100 + i // 16 * 10) + " DATA " + ",".join(str(b) for b in data[i : i + 16])
    )
(r / "build/loader.bas").write_text("\n".join(lines) + "\n")
