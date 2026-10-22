"""Generate a typed Atom BASIC loader; requires the 32 KiB expansion."""

from pathlib import Path

r = Path(__file__).resolve().parent
data = (r / "build/demo.bin").read_bytes()
lines = ["10 ?#2704=165;?#2705=90"]
for i in range(0, len(data), 4):
    lines.append(
        str(20 + i // 4 * 10)
        + " "
        + ";".join(f"?#{0x2800 + j:X}={b}" for j, b in enumerate(data[i : i + 4], i))
    )
lines.append(str(20 + (len(data) + 3) // 4 * 10) + " LINK #2800")
(r / "build/loader.bas").write_text("\n".join(lines) + "\n")
