# Game Boy DMG: byte turns alongside display servicing

Press A to change the blank background once. Hold A and it stays put; release and press again to restore the first shade. The display keeps refreshing while the rule state waits. The shade shows parity, not the exact count.

Build from the repository root:

```sh
python3 scripts/build-msx-gameboy-loops.py --assembler /path/to/asm198x --system nintendo-game-boy
```

Load generated `build/working/demo.gb` as a cartridge. Asm198x finalises the 32 KiB ROM-only header/checksums. Qualified reset is DMG default state without a boot ROM. It is not a CGB/double-speed or real-boot-ROM qualification.

## Reuse the rule

Keep demo.asm, caller.inc, routines.inc and presentation.inc together; include each implementation once. `turn_init` stores A into CTX, preserving A and flags. `turn_advance` adds compile-time STEP modulo 256, changing A, flags and count. Neither routine reads buttons, draws or waits.

CTX names four private WRAM bytes. This caller uses $C000–$C003 for count, previous A sample and a little-endian 16-bit display-service counter. Initialising count does not initialise the other bytes; the caller clears those once too. Previous input begins released, so a key held at entry is accepted on the first sample. Reserve these bytes in your own game's memory plan.

## Machine ownership

The caller disables maskable interrupts, sets a descending stack at $FFFE and owns LCD/VRAM, scrolling, BGP and JOYP. It does not return to firmware. The two-byte return addresses of internal CALLs still need stack space; plan your own call depth and avoid collision with other HRAM use.

It checks whether LCD is enabled, waits for VBlank before disabling it, then clears $8000–$9FFF with LCD off. It clears SCY/SCX, selects the palette and enables LCD/background with LCDC=$91. Replacing this setup inside a running game requires the same LCD shutdown constraint; it is not a per-frame clear.

`wait_frame` reads LY ($FF44): leave any current LY>=144 interval, then accept the next one. AF changes; LCD must remain enabled. It polls with interrupts disabled and does not count missed fields or guarantee the update fits. It spends CPU while waiting. A low-power HALT/interrupt caller is another ownership agreement, not a drop-in RET replacement.

`sample_action` selects action buttons with JOYP ($FF00)=$10, performs six settling reads, converts active-low bit 0 and resets the selection to $30. It stores the previous sample on every call, including holds/rejections. Return A=1 for a new press, else zero; AF/BC change. It claims the A button only, not a full directional or remappable controller API.

`show_turn` selects BGP=$E4 or $1B from count parity. AF changes. The cleared tile/map show colour zero across the background. This is a palette adapter, not a moving sprite or a numeric display. A step of three still flips parity once per action; read the count byte to check magnitude.

The service counter increments once per accepted display field and wraps after 65535. It is diagnostic service state, separate from the byte rule state. A real game needs its own explicit simulation/deadline policy and measured CPU/rendering budget.

## Customise and diagnose

`customise.asm` uses STEP/S=3: two actions give 0 → 3 → 6. One action still invokes the rule once. The byte contract needs a whole-number starting value and step from 0 through 255. Adding them gives at most 510, so one subtraction of 256 suffices in BASIC; the CPU's byte addition wraps naturally in assembly. The nonzero check starts at 100 with step 255 and reaches 99 then 98.

`mistakes/reset-each-command.asm` is deliberately broken: initialisation runs inside the repeated path, so the next iteration erases progress. Keep initialisation at startup and jump back to the command/update path to repair it. Repair is cold-started separately; the fault is not relabelled as a successful variation.

`--variant no-edge` treats a held A as another action each field. `--variant no-wait` removes display pacing: its service counter must fail the normal one-per-native-field guard. These are distinct deliberate faults, not advanced alternatives; their normal counterparts and the reset repair are executed separately.

An untimed world waits for an accepted action. A timed turn needs its own clock, expiry policy and ordering when a command arrives at the deadline. Display refresh or firmware interrupt activity does not automatically advance game rules. Blocking input is useful when nothing else needs main-loop service; continuing animation, music or deadlines require a different input/service policy.

## Verification

The original baseline probe remains separate. Run `scripts/verify-msx-gameboy-loops.py --native /path/to/binaries-and-locks --assembler /path/to/asm198x --system nintendo-game-boy --track assembly` from the repository root. The qualified released tools are Emu198x 0.44.1 and Asm198x 0.0.71, with verified archive and executable hashes plus before/after/committed producer locks.

The six common cold starts check normal use, step three, reset fault/repair, wraparound and nonzero initialisation. Idle, first accepted action, waiting/holding, ignored input and a second accepted action are retained as native captures and actual observations. Assembly adds no-edge and no-wait controls for eight cold starts. The complete 32 KiB CPU-visible ROM is compared with the finalised cartridge. The checker compares actual palette framebuffers for both parity states and checks the service counter against 120 native frames. This does not establish calibrated real-world speed or a catch-up policy.

`scripts/check-msx-gameboy-loops.py` independently decodes the records; falsification tests reject missing cases/stages, altered source/capture/payload/counts and false repairs. The additive three-route inventory does not expand the broad input/drawing/sound probe count or qualify new audio. No original-hardware, cassette-transfer, other model/firmware or whole-emulator claim follows.

## Primary references

Nintendo, *Game Boy Programming Manual*, version 1.1: P1 input/settling example; LCDC/LCD shutdown caution; LY values 0–153 and VBlank lines 144–153. This implementation follows the six-read action-button example; the retained older probe remains a separate observation.
