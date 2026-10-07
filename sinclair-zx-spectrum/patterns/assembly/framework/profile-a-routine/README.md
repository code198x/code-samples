# Profile a routine

Prepare a 32-byte row buffer in two ways, then use Asm198x, Debug198x and
Emu198x to find where the time went. The [teaching page](https://code198x.com/patterns/sinclair-zx-spectrum/assembly/framework/profile-a-routine/)
explains the experiment, the source-line report and the trade-off.

`loop.asm` writes one byte per iteration. `unrolled.asm` writes four and loops
eight times. Both fill `$9000`–`$901F` with `$47`, return HL=`$9020` and B=0,
and halt in the same caller. The reusable routine preserves A, flags, C, DE,
IX, IY and the interrupt state; CALL/RET require a working stack. Its 32-byte
destination must be writable and must not overlap its code or stack.

## Run the experiment

Use Python 3 and native [Asm198x](https://github.com/asm198x/asm198x/releases)
and [Emu198x](https://github.com/emu198x/emu198x/releases) binaries. The retained
run used Asm198x 0.0.59 and the Emu198x 0.31.0 build; provenance and executable
hashes are in `verification/`.

From this directory:

```sh
python3 verify.py --assembler /path/to/asm198x --emulator /path/to/emu198x-spectrum
```

If both tools are on PATH, `python3 verify.py` is enough. No Python packages,
firmware download or GUI are required. The script creates an unused, zero-filled
ROM, then loads a snapshot directly into RAM. This is a controlled routine
experiment, **not a ROM boot or tape-loading test**. Interrupts stay disabled.

The script assembles each source afresh, generates its matching `.debug198x`
sidecar and JSON listing, and asks Emu198x to measure exactly 4,096 master ticks.
It checks the buffer and adjacent guard bytes, return state, loaded code,
completed call, source coverage, routine coverage, static comparison and time
accounting. The maintained examples also have exact baseline expectations.

| Routine | Bytes | Measured T-states | Master ticks | Executed instructions |
|---|---:|---:|---:|---:|
| One byte per loop | 7 | 844 | 3,376 | 98 |
| Four bytes per loop | 13 | 532 | 2,128 | 74 |

The saving is 312 T-states (about 37%) for six extra bytes. Code is at `$C000`,
the buffer at `$9000` and the stack at `$FF00`, all in uncontended 48K RAM.
These are observations of this emulator configuration, not a claim about every
machine or workload. No physical-hardware check has been made.

Each `build/<variant>/` contains the source-matched binary, snapshot, sidecar,
symbols, static listing, executable `script.json` and complete `report.json`.
`build/results.json` contains hashes, selected checks and readable source-line
costs. A failed rerun removes any previous passing summary. Build outputs are
ignored by Git; the retained evidence in `verification/` is deliberately small.

## What the report measures

The 48K runtime reports 14 MHz master ticks, four per CPU T-state. The routine's
exclusive cost includes its RET; the caller owns CALL. The caller's inclusive
cost includes the routine, so adding both inclusive totals would double-count.

The whole capture is equally long for both versions. The saved instruction time
becomes additional HALT waiting: 512 ticks for the loop, 1,760 for the four-byte
version. HALT itself is an instruction; subsequent waiting is a separate bucket.
Interrupt and partial-instruction buckets remain visible and are zero in these
baseline captures. Host wall-clock duration is never used for the comparison.

Asm198x's listing gives DJNZ an 8–13 T-state range. Emu198x weights this by the
observed execution count. The routine ranges are therefore 689–849 and 497–537
T-states; their measured totals are 844 and 532. A static range describes possible
instruction outcomes. It is not an independently measured result or a proof of
the emulator's timing.

The generated script's `profile_cycles` step is also the MCP tool's argument
shape after removing `action`. Load the matching sidecar with `load_debug_info`
first. Routine ranges come from `fill_row`/`end_fill_row`, not from the next
label: the internal `fill_loop` label is part of the routine.

## Try one change

Copy `loop.asm` to `two-at-a-time.asm`. Change `ld b,32` to `ld b,16`, then add
a second `ld (hl),a` / `inc hl` pair immediately before DJNZ. Predict which
source-line costs will change, then run:

```sh
python3 verify.py --source two-at-a-time.asm --output build/two-at-a-time
```

An edited source must remain a single file with the four extent labels and the
same 32-byte fill/caller contract. This mode measures the new result without
enforcing the maintained examples' exact timing. The expected result is a
nine-byte routine taking 636 T-states; it performs sixteen DJNZ instructions.

For a controlled mistake, leave B at 32 in the four-byte version. It writes past
the buffer. Use `--source too-many.asm --ticks 16384 --output build/too-many`
to let that faulty call finish and check its output. Restore B to 8 to recover. A 256-tick capture also fails
because the routine has not finished; a shorter window is not an optimisation.

Do not move the buffer into screen memory and keep these timing claims. Display
contention changes the conditions. Likewise, a variable-length routine needs a
remainder path when the length is not divisible by four. That is further work,
not behaviour this fixed-size example promises.

## Evidence and sources

Run `python3 verification/run_checks.py` (with the same optional `--assembler`
and `--emulator` arguments) to repeat the baseline, guided edit, buffer overrun,
unfinished capture and stale-summary checks using the real binaries.

- `verification/results.json`: the maintained examples' measured costs, hashes
  and per-line evidence. `verification/provenance.json` identifies the tool
  artifacts. `verification/checks.json` records the edited example and deliberate
  failures exercised with the same executables.
- Zilog, [Z80 CPU User Manual, UM008011-0816](https://www.zilog.com/docs/z80/um0080.pdf),
  instruction entries LD (HL),r (printed p. 79), INC ss (p. 198), DJNZ (pp.
  278–279), LD r,n and RET: operation, flag behaviour and nominal costs.
- Emu198x's [cycle-profile accounting contract](https://github.com/emu198x/emu198x/blob/main/knowledge/decisions/cycle-profile-accounting.md):
  clock conversion, source joins, explicit routine extents, call accounting and
  partial/waiting buckets.
