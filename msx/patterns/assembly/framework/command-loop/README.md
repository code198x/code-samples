# MSX1: reusable byte turns through BIOS services

Press Space to advance once; holding it does not repeat. Release it before another action. Escape returns to BASIC after release, clearing firmware repeats. Escape is checked while waiting for the next command; release a previously accepted Space before quitting.

Build from the repository root:

```sh
python3 scripts/build-msx-gameboy-loops.py --assembler /path/to/asm198x --system msx
```

Keep demo.asm and the three includes together. Enter generated `build/working/load.bas` under the normal recorded MSX1 NTSC BIOS/BASIC; it reserves memory with CLEAR 200,49151, reads/POKEs the actual 164-byte image at $C000–$C0A3 and defines USR at $C000. Allow RUN to finish before entering `SCREEN 0:WIDTH 40:CLS:A=USR(0)`. The verifier requires exact loaded-byte equality before entry, rather than assuming typing completion means the BASIC loader completed.

## Reuse the rule and adapters

`turn_init`: A becomes the labelled turn_count byte. A and flags are preserved. Call once at startup. `turn_advance`: add compile-time byte STEP modulo 256; changes A, flags and turn_count. Neither routine reads input, draws or checks time. Include each implementation once in your own build, supplying origin and settings as demo.asm does.

The small image includes its state byte and eight-byte mutable display buffer. CLEAR reserves the entire area above BASIC's new ceiling, including unused space; it is not a claim that BASIC loses only 164 bytes. Do not overlap another buffer or code image. The normal BIOS/BASIC mapping and enabled firmware interrupts must remain available; no slot or mapper is changed here.

`new_action` uses BIOS SNSMAT ($0141): row 8 bit 0 is Space; row 7 bit 2 is Escape; zero means down. SNSMAT and the command reader change AF. The reader waits for Space release before accepting a fresh action, so a key already held at startup is not immediately accepted. KILBUF ($0156) clears buffered firmware repeats before return. This is two-command input, not a general keyboard scanner or autorepeat policy.

`show_turn` forms TURN $hh in the image's eight-byte buffer and calls BIOS LDIRVM ($005C) with HL=source, DE=0, BC=8. It writes the first eight cells of the selected SCREEN 0 default name table and leaves the cursor alone. Treat all main registers/flags as clobbered by this adapter; the top-level caller saves/restores AF/BC/DE/HL/IX/IY around the complete session. Those saves use 12 stack bytes plus nested helper/BIOS/interrupt needs on the existing balanced BASIC stack. The caller returns through RET, not a jump into a guessed interpreter address.

The displayed byte is hexadecimal: $0A is ten, $FF is 255, then a unit step wraps to $00. Change the presentation adapter for another mode or table base. BIOS access preserves manufacturer-specific hardware handling; it does not make an arbitrary display layout portable.

## Customise and diagnose

`customise.asm` uses STEP/S=3: two actions give 0 → 3 → 6. One action still invokes the rule once. The byte contract needs a whole-number starting value and step from 0 through 255. Adding them gives at most 510, so one subtraction of 256 suffices in BASIC; the CPU's byte addition wraps naturally in assembly. The nonzero check starts at 100 with step 255 and reaches 99 then 98.

`mistakes/reset-each-command.asm` is deliberately broken: initialisation runs inside the repeated path, so the next iteration erases progress. Keep initialisation at startup and jump back to the command/update path to repair it. Repair is cold-started separately; the fault is not relabelled as a successful variation.

`--variant no-edge` deliberately removes release gating. A held Space then spends repeated turns and must fail the normal press guard. Deliberate auto-repeat needs an explicit delay and repeat interval.

An untimed world waits for an accepted action. A timed turn needs its own clock, expiry policy and ordering when a command arrives at the deadline. Display refresh or firmware interrupt activity does not automatically advance game rules. Blocking input is useful when nothing else needs main-loop service; continuing animation, music or deadlines require a different input/service policy.

## Verification

The original baseline probe remains separate. Run `scripts/verify-msx-gameboy-loops.py --native /path/to/binaries-and-locks --assembler /path/to/asm198x --system msx --track assembly` from the repository root. The qualified released tools are Emu198x 0.44.1 and Asm198x 0.0.71, with verified archive and executable hashes plus before/after/committed producer locks.

The six common cold starts check normal use, step three, reset fault/repair, wraparound and nonzero initialisation. Idle, first accepted action, waiting/holding, ignored input and a second accepted action are retained as native captures and actual observations. Assembly adds a seventh no-edge cold start, full exact payload readback before USR, actual VDP I/O write traces (address zero followed by eight character bytes), and working BASIC arithmetic after return. Raw I/O traces are bounded to one native frame and 4096 sampled events; retained records identify the VDP-write subset. The state byte and the actual emitted character bytes must agree.

`scripts/check-msx-gameboy-loops.py` independently decodes the records; falsification tests reject missing cases/stages, altered source/capture/payload/counts and false repairs. The additive three-route inventory does not expand the broad input/drawing/sound probe count or qualify new audio. No original-hardware, cassette-transfer, other model/firmware or whole-emulator claim follows.

## Primary references

ASCII/Microsoft, *MSX Technical Data Book*: Advanced Programming Guide BIOS entries SNSMAT ($0141), KILBUF ($0156), LDIRVM ($005C); BASIC Reference Guide CLEAR and DEFUSR/USR. The MSX standard requires BIOS access for portable non-VDP I/O; this caller also uses BIOS for video transfer.
