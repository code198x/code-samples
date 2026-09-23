# Same random choices, wrong displayed position

This optional step-04 investigation isolates one omitted call to
`set_enemy_hibit` at the end of `spawn_enemy`. The calculated coordinate remains
correct, but its ninth bit does not reach the sprite register. The ordinary
game, random generator and random-call order remain unchanged.

## Build and run

From this folder, with Python 3 and Asm198x:

```sh
python3 prepare.py /tmp/starfield-position
asm198x --dialect acme --prg /tmp/starfield-position/baseline.asm -o /tmp/starfield-position/baseline.prg
asm198x --dialect acme --prg /tmp/starfield-position/faulty.asm -o /tmp/starfield-position/faulty.prg
asm198x --dialect acme --prg /tmp/starfield-position/repaired.asm -o /tmp/starfield-position/repaired.prg
python3 verify.py --emulator /path/to/emu198x-c64 --build /tmp/starfield-position
```

Use an appropriate temporary path on our own machine. Load each PRG on a PAL
C64 emulator and enter RUN. The screen shows calls 10–12 in hexadecimal. All
twelve records are available in memory and the verifier output. The display is
a table of observed registers, not a screenshot of a sprite at each position.

`prepare.py` checks the original source hash. It changes startup to enter
`trial.asm` and appends the isolated test. Only the faulty variant replaces the
spawn routine's high-bit call with three NOPs. That preserves its byte footprint,
not execution timing. Baseline and repaired PRGs are byte-identical.

## A reproducible scenario needs more than a seed

The guest fixture sets seed 1, initial `$d010=$ab` and makes twelve consecutive
calls to the original `spawn_enemy`, always with X=0 (enemy 0/sprite 2), Y=80.
There are no movement, collision or joystick updates between calls. The verifier
uses the same R/U/N/Return press/release schedule on every cold run; it supplies
no gameplay inputs and performs no memory pokes. Initialisation and diagnostic
writes are visible in the guest fixture.

`$ab` has sprite 2's bit clear and deliberately sets some unrelated sprite bits.
Only bit 2 may change. Reusing the same enemy slot tests clearing after setting,
not merely starting with a convenient zero. The snapshot contains:

| Byte | Meaning |
|---|---|
| 0 | LFSR byte after this call |
| 1, 2 | Logical X low byte and high byte |
| 3 | VIC-II sprite 2 X low register, `$d004` |
| 4 | Shared sprite high-bit register, `$d010` |

Records begin at `$3803`, five bytes each. `$3800=1` marks completion; `$3801=12`
and `$3802=60` identify the call count and bytes recorded. The final screen shows
records 10, 11 and 12. We hide sprites after logging to keep the table readable.

## Predict the first difference

The first ten calls agree. Before revealing the answer in the lesson, use the
mapping `24 + b + floor(b/8)` on the next two random bytes, 232 and 205. Which
part of the position needs the extra bit, and what does the low byte mean alone?

The first divergent record is call 11. Its byte is 232 (`$e8`), mapping to
285 (`$011d`). Both variants store low 29/high 1 in game state and write 29 to
`$d004`. Baseline/repair change `$d010` from `$ab` to `$af`; the fault leaves `$ab`,
so sprite 2's register-selected coordinate is 29 instead of 285.

Call 12 maps byte 205 to 254 (`$00fe`). The repaired helper clears bit 2 again,
returning `$d010` to `$ab` without changing the other sprite bits. Merely setting
bit 2 forever would turn that coordinate into 510. Copying `enemy_xhi_tbl` over
the entire register would overwrite other sprites' high bits.

The repair restores the original call. Check all twelve records, the unchanged
random sequence and low bytes, both sides of 255, preservation of unrelated bits,
and a second cold baseline run. Return to the untouched step-04 source afterwards.

## Evidence and limits

[Native results](results.json) cover baseline, fault, repair and a repeated
baseline on PAL C64 emulation. They record exact source/PRG/emulator hashes and
all twelve observations. An independent integer calculation checks every mapped
position. This is a controlled spawn-to-register test, not a complete gameplay
replay, collision test, timing-equivalence test or original-hardware verification.
The faulty table was visually inspected. The original game source is unchanged.

Hardware reference: Commodore Business Machines, *Commodore 64 Programmer's
Reference Guide*, sprite X/Y position-register discussion and Appendix G, VIC-II
register map: `$d004` holds sprite 2's low X byte; `$d010` contains the individual
high X bits for sprites 0–7. The source's `enemy_d010_bit` table selects `$04`
for enemy 0. No new emulator feature is assumed: verification uses the existing
native script runner, memory reads and screenshot capture.

C07c remains separate: move a cosmetic random call and compare consumption order.
This fixture deliberately does not introduce that second cause of divergence.

The website build completed with 2,468 pages. Browser review confirmed the
prediction table and folded hints/repair explanation render correctly.
