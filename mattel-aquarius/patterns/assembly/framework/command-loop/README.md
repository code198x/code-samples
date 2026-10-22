# Aquarius: an assembly loop with a separate byte update

Press 1: TURN $00 becomes TURN $01. Release and press again for $02. Q returns to BASIC after release. Untimed world state waits for the player; display refresh continues.

Build from the repository root:

```sh
python3 scripts/build-aquarius-mtx-loops.py --assembler /path/to/asm198x --system mattel-aquarius
```

Enter generated `build/working/load.bas` line by line under normal firmware. The loader is generated from Asm198x's actual bytes, not a separately maintained machine-code list. The verifier compares the CPU-visible load with the exact assembled payload before entry. Firmware is never redistributed.

On the unexpanded Aquarius, CLEAR 50,15871 keeps BASIC below $3E00. READ/POKE installs the 152-byte image at $3E00–$3E97, including its one labelled state byte; the USR vector at 14340/14341 points at $3E00. PRINT CHR$(11):X=USR(0) clears once and calls it. Reserve that region in any mixed-language project; the loader's I/A/X variables, line numbers and the changed USR vector also need coordination. The caller preserves AF, BC, DE, HL, IX and IY on BASIC's existing stack, leaves interrupts alone and returns through the original USR frame. It does not alter the scrambler or memory mapper.

## Reuse the pieces

Keep demo.asm and the three includes together. `demo.asm` supplies origin and settings; include each implementation once in your own build.

- `turn_init`: A becomes the persistent byte. LD does not change flags; A is preserved.
- `turn_advance`: add compile-time STEP modulo 256. A/flags change; no input, presentation or time access.
- `caller.inc`: initialises once and decides when the rule may run.
- `presentation.inc`: owns the machine-specific output adapter.

`new_action` samples keyboard row 7 through IN A,(C) at $7FFF: bit 2 is 1, bit 3 is Q, both active-low. It first waits for release, then returns A=1 for an action or A=0 for quit; Q wins a simultaneous sample. It waits for Q release before returning to BASIC. AF/BC change. Other keys are ignored. This is not a full keyboard translator or a buffered-character reader. Writing port $FF would change the software scrambler; this routine only reads it.

`show_turn` writes eight ASCII text cells at $3029–$3030, beginning with TURN $. It changes AF/BC/DE/HL and no cursor or colour state. $0A means ten; $FF is 255 and the next action wraps to $00. The normal BASIC text/colour setup must remain valid. The byte lives inside the loaded image and moves with its assembled labels. Internal nested calls need four bytes of return addresses in addition to the entry's twelve saved register bytes and the interpreter/interrupt stack requirements.

## Customise and diagnose

Build `--variant step-three` to use `customise.asm`. STEP=3 gives 0 → 3 → 6 without extra state or image bytes. Hexadecimal digits show the amount directly.

`mistakes/reset-each-command.asm` is deliberately broken. RESET_EACH=1 puts state initialisation inside the iteration, so the next pass erases the action's result. Use the original startup-only initialisation to repair it; the repaired path is cold-started separately.

`--variant no-edge` is a separate deliberately broken control: it treats a held key as repeated actions. It must fail the normal one-action-per-press guard. It is not an advanced input method; deliberate auto-repeat needs a stated initial delay and repeat policy.

A timed turn needs an explicit timeout policy. A running display or service counter does not mean the world advances at that rate. A more complex renderer or audio service also needs its own ownership and worst-case timing agreement.

## Verification

`scripts/verify-aquarius-mtx-loops.py --native /path/to/binaries-and-locks --assembler /path/to/asm198x --system mattel-aquarius --track assembly` cold-starts seven variants: normal, custom step, reset fault, repair, wrap, nonzero start and disabled edge detection. Inputs, idle/held/released actions, exact loaded bytes and actual visible output are retained. Q must return to firmware that calculates 2+3.

The independent retained checker and falsification tests bind maintained source, loaded bytes, video/context observations, native images and released-tool producer locks. The qualified tools are Emu198x 0.44.1 and Asm198x 0.0.71. No original-hardware, cassette, other firmware/model or whole-emulator claim follows.

## References

Original Aquarius S2 ROM (qualified hash in the record), with Kenny Millar's annotated disassembly at https://aquarius.mattpilz.com/s2-disassembly.php (USR jump at $3803, RAM limit and output); Mattel's *Aquarius Guide to Home Computing* (1982), clear-screen/CHR$. Martin van der Steenoven's technical notes are a supporting port/memory cross-check, not a manufacturer manual.
