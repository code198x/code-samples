# Bitmap Addressing

Convert a pixel coordinate to its Spectrum bitmap byte, then step to the row
below. The [pattern](https://code198x.com/patterns/sinclair-zx-spectrum/assembly/rendering/bitmap-addressing/)
explains the interleaved layout and alternatives.

`bitmap-addressing.inc` is the existing Code198x listing moved unchanged from
the website, apart from comments and end labels for profiling. Its original
website revision and listing hash are in `verification/baseline.json`.
This is maintained Code198x sample code under MIT, following the family code
licence decision; no original third-party source project is asserted.

## Contract

- `pixel_addr`: D = Y (0–191), E = X (0–255); returns HL = bitmap byte address.
  Changes A, H, L and flags; preserves BC and DE. Pixel mask is separate:
  `$80 >> (x AND 7)`.
- `pixel_down`: HL = a bitmap byte on row 0–190; returns the same byte column
  on the next row. Changes A, H, L and flags; preserves BC and DE.
- Neither routine checks its inputs. Stepping down from row 191 enters
  attribute memory. Both need an ordinary writable CALL/RET stack.
- No lookup data or persistent state; routines do not write the screen.
  The caller owns coordinates, plotting and its interrupt policy.

`caller.asm` starts directly in 48K PAL RAM at `$8000`, disables interrupts,
sets SP to `$FF00`, and records 16 rows of results at `$9000`–`$CFFF`.
The verifier selects the row range through two labelled data bytes before
execution. Each input records two little-endian words: its bitmap address
and its next-row address (zero for excluded row 191). The caller checks BC
and DE after each call and halts with `done=1`; contract failure uses 255.

## Run

With Python 3.13+, Asm198x and Emu198x installed:

```sh
python3 verification/verify.py --output /tmp/bitmap-addressing
```

Use `--assembler /path/to/asm198x`, `--emulator /path/to/emu198x-spectrum`,
and optionally `--pasmo /path/to/pasmo`. No Python packages are required.
The verifier supplies an unused zero-filled ROM and starts an Asm198x snapshot
in RAM. It does not boot a ROM or load a tape.

The retained run checks all 49,152 pixel inputs and all 48,896 valid next-row
pixel inputs, covering 6,112 distinct next-row byte addresses. The independent
oracle enumerates physical bitmap memory by third, scanline, character row
and column rather than copying the routine's rotations. It checks complete
calls, BC/DE preservation, SP, DI, output guards and the same-build loaded
code/state. Asm198x and Pasmo binaries agree for every caller.

Dynamic profiles measure 117 T-states for `pixel_addr`. Separate row probes
measure 26 within a character cell, 65 across an ordinary character boundary
and 46 across a third. These include RET and exclude CALL. Code, result buffer
and stack are uncontended; the routines compute screen addresses without
accessing screen RAM. An extra, deliberately out-of-contract row-191 probe
confirms that the result is `$5800` plus the byte column.

The checker rejects assembled wrong-base and wrong-row mutations. Missing
completion, truncated memory reads, incorrect call counts or timing mismatches
fail the run; a failed rerun removes any stale passing summary first.
`verification/results.json` retains hashes and counts, not snapshots or ROMs.
Scratch is created only in the supplied output directory and can be removed
after inspection. Regenerate evidence after editing a source or the observer.

These are emulator observations in this configuration, not original-hardware,
contention, ROM-boot or other-model qualification. The Zilog *Z80 CPU User
Manual*, UM008011-0816, instruction tables are the timing reference used by the
pattern; Sinclair's *ZX Spectrum BASIC Programming*, chapter 24, describes
screen memory order. A 384-byte line table is an alternative when lookup speed
matters more than memory.

## Released-tool CI run

The Pattern evidence workflow also runs this unchanged observer on Ubuntu
24.04 x86-64 with the published Asm198x 0.0.65 and Emu198x Spectrum 0.34.0
binaries. Both archive hashes are pinned and checked before execution. The
job includes a wrong-checksum control and requires the full output, timing
and assembled-mutation checks above. CI does not install Pasmo, so the earlier
record remains the separate alternate-assembler comparison.

The uploaded compact result identifies source, observer, executable and binary
hashes. Its companion release-input report records tags, archive hashes, host
and samples revision. They are retained for 14 days; the committed historical
record is preserved. This is one tested released-tool combination for this
fixture, not a claim that every family tool version or Spectrum model works.
