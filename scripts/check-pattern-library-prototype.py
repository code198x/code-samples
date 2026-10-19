from __future__ import annotations

import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = (
    ROOT / "commodore-64/patterns/assembly/framework/input-to-sound/build/verification"
)
OUT.mkdir(parents=True, exist_ok=True)


def run(command: list[str], cwd: Path) -> str:
    r = subprocess.run(
        command, cwd=cwd, capture_output=True, text=True, timeout=90, check=False
    )
    if r.returncode:
        raise RuntimeError(f"{command}: {r.returncode}\n{r.stdout}\n{r.stderr}")
    return r.stdout


base = "patterns/assembly/framework/input-to-sound"
for machine, flags in [
    ("sinclair-zx-spectrum", ["--dialect", "pasmo", "--cpu", "z80"]),
    ("nintendo-nes", ["--dialect", "ca65"]),
    ("commodore-amiga", ["--dialect", "vasm", "--exe"]),
]:
    run(
        ["asm198x", *flags, "check.asm", "-o", str(OUT / f"{machine}.bin")],
        ROOT / machine / base,
    )
c64 = ROOT / "commodore-64" / base
run(["make"], c64)
sym = {
    k: int(v, 16)
    for k, v in (
        line.split(" = $") for line in (c64 / "build/demo.sym").read_text().splitlines()
    )
}
stages = [0, 16, 16, 16, 16, 16, 16, 16, 0, 16, 24, 8, 24, 0]
commands = [
    f'load "{c64}/build/demo.prg" 0',
    f"break exec ${sym['update']:04x}",
    "g $0810",
    "delete 1",
]
for i, mask in enumerate(stages):
    commands += [
        f"jpdb 1 ${(mask ^ 255):02x}",
        f"break exec ${sym['frame_done']:04x}",
        "x",
        "delete 1",
        f'bsave "{OUT}/{i}.bin" 0 ${sym["note_frames"]:04x} ${sym["trigger_count"]:04x}',
        "io d400",
    ]
    if i < len(stages) - 1:
        commands += [f"break exec ${sym['update']:04x}", "x", "delete 1"]
commands += ["quit"]
mon = OUT / "check.mon"
mon.write_text("\n".join(commands) + "\n")
run(
    [
        "x64sc",
        "-console",
        "-default",
        "-model",
        "c64",
        "-controlport2device",
        "io",
        "-warp",
        "+sound",
        "-limitcycles",
        "16000000",
        "-monlog",
        "-monlogname",
        str(OUT / "monitor.log"),
        "-initbreak",
        "ready",
        "-moncommands",
        str(mon),
    ],
    OUT,
)
previous = 0
expected_count = 0
frames = 0
observations = []
gates = [
    int(line.split()[5], 16)
    for line in (OUT / "monitor.log").read_text(encoding="latin-1").splitlines()
    if line.startswith(">C:d400")
]
for i, mask in enumerate(stages):
    if mask & ~previous & 16:
        expected_count += 1
        frames = 6
    elif frames:
        frames -= 1
    actual = list((OUT / f"{i}.bin").read_bytes())
    assert actual == [frames, expected_count], (i, actual, frames, expected_count)
    assert gates[i] == (0x41 if frames else 0x40), (i, gates[i], frames)
    observations.append(
        {
            "held": mask,
            "note_frames": actual[0],
            "triggers": actual[1],
            "sid_control": gates[i],
        }
    )
    previous = mask
# Negative control: a deliberately held-state caller must retrigger on a hold.
mutant = (c64 / "demo.asm").read_text().replace("lda joy2_new", "lda joy2")
for relative in [
    "../../input/joystick-reading/joystick.inc",
    "../../audio/sid-note-trigger/sid-note.inc",
]:
    mutant = mutant.replace(relative, str((c64 / relative).resolve()))
(OUT / "mutant.asm").write_text(mutant)
run(["asm198x", "--dialect", "acme", "--prg", "mutant.asm", "-o", "mutant.prg"], OUT)
negative = OUT / "negative"
negative.mkdir(exist_ok=True)
(negative / "check.mon").write_text(
    mon.read_text()
    .replace(str(c64 / "build/demo.prg"), str(OUT / "mutant.prg"))
    .replace(str(OUT) + "/", str(negative) + "/")
    .replace(str(negative / "mutant.prg"), str(OUT / "mutant.prg"))
)
run(
    [
        "x64sc",
        "-console",
        "-default",
        "-model",
        "c64",
        "-controlport2device",
        "io",
        "-warp",
        "+sound",
        "-limitcycles",
        "16000000",
        "-initbreak",
        "ready",
        "-moncommands",
        str(negative / "check.mon"),
    ],
    negative,
)
assert list((negative / "2.bin").read_bytes())[1] == 2, (
    "Negative control did not retrigger"
)
assert observations[2]["triggers"] == 1, "Held-state regression escaped positive checks"
print(
    json.dumps(
        {
            "c64_composition": "passed",
            "stages": observations,
            "negative_control": "held-state caller retriggers as expected",
        },
        indent=2,
    )
)
# Real 6502 turn routine, exhaustively tested over all open actor squares and both targets.
turn = ROOT / "commodore-64/patterns/assembly/ai/local-turn"
board = [
    [int(n) for n in line.split("!byte ")[1].split(",")]
    for line in (turn / "local-turn.inc").read_text().splitlines()
    if line.startswith("    !byte")
]
cases = [
    (x, y, mode)
    for y in range(7)
    for x in range(9)
    if board[y][x] == 0
    for mode in (0, 1)
]
source = '*=$0801\n !byte $0b,$08,$0a,$00,$9e\n !text "2064"\n !byte 0,0,0\n*=$0810\n'
for i, (x, y, mode) in enumerate(cases):
    source += f" lda #{x}\n sta actor_x\n lda #{y}\n sta actor_y\n lda #{mode}\n sta target_mode\n jsr choose_target\n jsr choose_turn\n lda choice\n sta results+{i}\n"
source += (
    'done: jmp done\n!source "'
    + str(turn / "local-turn.inc")
    + '"\n!source "'
    + str(turn / "use.asm")
    + '"\nresults: !fill '
    + str(len(cases))
    + ",0\n"
)
(OUT / "turn.asm").write_text(source)
run(
    [
        "asm198x",
        "--dialect",
        "acme",
        "--prg",
        "turn.asm",
        "--sym=turn.sym",
        "-o",
        "turn.prg",
    ],
    OUT,
)
ts = {
    k: int(v, 16)
    for k, v in (
        line.split(" = $") for line in (OUT / "turn.sym").read_text().splitlines()
    )
}
(OUT / "turn.mon").write_text(
    f'load "{OUT}/turn.prg" 0\nbreak exec ${ts["done"]:04x}\ng $0810\nbsave "{OUT}/turn-results.bin" 0 ${ts["results"]:04x} ${ts["results"] + len(cases) - 1:04x}\nquit\n'
)
run(
    [
        "x64sc",
        "-console",
        "-default",
        "-warp",
        "+sound",
        "-limitcycles",
        "16000000",
        "-initbreak",
        "ready",
        "-moncommands",
        str(OUT / "turn.mon"),
    ],
    OUT,
)
actual = (OUT / "turn-results.bin").read_bytes()
assert len(actual) == len(cases)
for i, (x, y, mode) in enumerate(cases):
    target = (5, 1 if mode else 3)
    legal = []
    for direction, (dx, dy) in enumerate([(0, -1), (-1, 0), (0, 1), (1, 0)]):
        nx, ny = x + dx, y + dy
        if 0 <= nx < 9 and 0 <= ny < 7 and not board[ny][nx]:
            legal.append(((nx - target[0]) ** 2 + (ny - target[1]) ** 2, direction))
    expected = min(legal)[1] if legal else 255
    assert actual[i] == expected, (i, (x, y, mode), actual[i], expected)
receipt = {
    "status": "passed",
    "configuration": "VICE 3.10 PAL C64, monitor-loaded PRG, entered at $0810 after ROM boot; simulated control-port pins",
    "composition": observations,
    "turn_cases": len(cases),
    "negative_control": "held-state mutation retriggered on second held sample; positive caller did not",
    "other_machines": "This recipe only assembles the other-machine fragments; their execution records are pattern-library-spectrum.json, pattern-library-amiga.json and pattern-library-nes.json",
    "sources": {
        str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
        for m in [
            "commodore-64",
            "sinclair-zx-spectrum",
            "nintendo-nes",
            "commodore-amiga",
        ]
        for p in (ROOT / m / base).glob("*")
        if p.is_file() and p.suffix in [".inc", ".asm"]
    },
}
receipt["sources"][str((turn / "use.asm").relative_to(ROOT))] = hashlib.sha256(
    (turn / "use.asm").read_bytes()
).hexdigest()
receipt["sources"][str((turn / "local-turn.inc").relative_to(ROOT))] = hashlib.sha256(
    (turn / "local-turn.inc").read_bytes()
).hexdigest()
(OUT / "results.json").write_text(json.dumps(receipt, indent=2) + "\n")
print(
    "PASS: assembled all four machines; C64 composed input/edge/SID gate, and",
    len(cases),
    "local-turn cases",
)
