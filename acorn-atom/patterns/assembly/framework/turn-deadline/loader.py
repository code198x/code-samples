"""Generate a typed Atom BASIC loader; requires the 32 KiB expansion."""

from pathlib import Path

r = Path(__file__).resolve().parent
data = (r / "build/demo.bin").read_bytes()
lines = ["10 ?#5F0C=165;?#5F0D=90"]
for i in range(0, len(data), 4):
    lines.append(
        str(20 + i // 4 * 10)
        + " "
        + ";".join(f"?#{0x6000 + j:X}={b}" for j, b in enumerate(data[i : i + 4], i))
    )
lines.append(str(20 + (len(data) + 3) // 4 * 10) + " LINK #6000")
(r / "build/loader.bas").write_text("\n".join(lines) + "\n")
