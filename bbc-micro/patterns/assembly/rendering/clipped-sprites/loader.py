"""Package the original MODE4 program as a BBC BASIC DATA loader."""

from pathlib import Path

root = Path(__file__).resolve().parent
data = (root / "build/demo.bin").read_bytes()
lines = [
    "10 MODE 4",
    "20 HIMEM=&3000",
    f"30 FOR I%=0 TO {len(data) - 1}:READ B%:I%?&3000=B%:NEXT",
    "40 CALL &3000",
]
for i in range(0, len(data), 16):
    lines.append(
        f"{100 + i // 16 * 10} DATA " + ",".join(str(b) for b in data[i : i + 16])
    )
(root / "build/loader.bas").write_text("\n".join(lines) + "\n")
