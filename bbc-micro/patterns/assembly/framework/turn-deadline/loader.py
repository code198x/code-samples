"""Generate our own code as DATA for stock BBC/Electron BASIC to install."""

from pathlib import Path

p = Path(__file__).resolve().parent
code = (p / "build/demo.bin").read_bytes()
lines = [
    "10 MODE 6",
    "15 HIMEM=&2F00",
    '20 PRINT "SPACE:TURN T:TIMER RESET:EXIT"',
    '25 PRINT "TURN EX TIMER"',
    f"30 FOR I%=0 TO {len(code) - 1}:READ B%:I%?&3000=B%:NEXT",
    "40 CALL &3000",
]
for i in range(0, len(code), 16):
    lines.append(
        str(100 + i // 16 * 10) + " DATA " + ",".join(map(str, code[i : i + 16]))
    )
(p / "build/loader.bas").write_text("\n".join(lines) + "\n")
