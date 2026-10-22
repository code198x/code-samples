# MTX500: an assembly loop with a separate byte update

Press Space: the backdrop changes once. Hold it: the colour stays put. Release and press again to restore the first colour. Untimed world state waits for the player; display refresh continues.

Build from the repository root:

```sh
python3 scripts/build-aquarius-mtx-loops.py --assembler /path/to/asm198x --system memotech-mtx
```

Enter generated `build/working/load.bas` line by line under normal firmware. The loader is generated from Asm198x's actual bytes, not a separately maintained machine-code list. The verifier compares the CPU-visible load with the exact assembled payload before entry. Firmware is never redistributed.

MTX500 BASIC loads the 135-byte image at $E000–$E086 through the existing READ/POKE route, then LET X=USR(57344) enters it. This caller deliberately takes over until reset: DI disables maskable IRQs, SP becomes $F7F0 and the caller owns keyboard drive plus VDP status/control ports. It does not return to BASIC or claim OS coexistence. The small loader's allocations do not make these addresses a general allocator for a large BASIC project. A real game must reserve code, context and stack in its own memory plan.

## Reuse the pieces

Keep demo.asm and the three includes together. `demo.asm` supplies origin and settings; include each implementation once in your own build.

- `turn_init`: A becomes the persistent byte. LD does not change flags; A is preserved.
- `turn_advance`: add compile-time STEP modulo 256. A/flags change; no input, presentation or time access.
- `caller.inc`: initialises once and decides when the rule may run.
- `presentation.inc`: owns the machine-specific output adapter.

Define CTX at four private RAM bytes. This caller uses $DF00–$DF03: count, previous Space sample and a little-endian 16-bit display-service counter. `turn_init` changes only count; initialise the other three once as the caller does.

`sample_action` drives keyboard column 7 through OUT $05=$7F, reads Space from port $06 bit 0 (active-low), compares with the old sample and stores the new sample on every call. It returns 1 only for a new press, otherwise zero; AF/BC change. Saving the previous sample only on an accepted action would break future edge decisions.

`wait_frame` clears stale VDP status and waits for a fresh bit-7 indication. AF changes. It exclusively owns status/control port $02; it cannot coexist unchanged with another reader or a firmware VDP ISR. The caller increments its service counter every frame even while count stays put. That count wraps after 65535 and is diagnostic service state, not a compulsory rule clock or deadline.

`show_turn` uses count parity to select backdrop index 2 or 3 through VDP register 7; AF changes. It does not draw a CPU-mapped character screen. The screen is blanked and the VDP owns refresh without CPU rendering every scanline. The retained checks compare actual framebuffers: odd/even states differ, and two single-step actions return to the original picture. Internal helper calls use the existing takeover stack; reserve interrupt and game-call depth separately in a larger design.

## Customise and diagnose

Build `--variant step-three` to use `customise.asm`. STEP=3 gives 0 → 3 → 6 without extra state or image bytes. The backdrop still changes once per accepted action: parity alone cannot show the magnitude. Read the state byte when debugging; do not infer an exact count from a two-colour indicator.

`mistakes/reset-each-command.asm` is deliberately broken. RESET_EACH=1 puts state initialisation inside the iteration, so the next pass erases the action's result. Use the original startup-only initialisation to repair it; the repaired path is cold-started separately.

`--variant no-edge` is a separate deliberately broken control: it treats a held key as repeated actions. It must fail the normal one-action-per-press guard. It is not an advanced input method; deliberate auto-repeat needs a stated initial delay and repeat policy.

A timed turn needs an explicit timeout policy. A running display or service counter does not mean the world advances at that rate. A more complex renderer or audio service also needs its own ownership and worst-case timing agreement.

## Verification

`scripts/verify-aquarius-mtx-loops.py --native /path/to/binaries-and-locks --assembler /path/to/asm198x --system memotech-mtx --track assembly` cold-starts seven variants: normal, custom step, reset fault, repair, wrap, nonzero start and disabled edge detection. Inputs, idle/held/released actions, exact loaded bytes and actual visible output are retained. The separate service counter must advance by approximately one per native field while rule state remains unchanged without a new press. This proves the bounded display-service loop, not calibrated game speed or every VDP timing edge.

The independent retained checker and falsification tests bind maintained source, loaded bytes, video/context observations, native images and released-tool producer locks. The qualified tools are Emu198x 0.44.1 and Asm198x 0.0.71. No original-hardware, cassette, other firmware/model or whole-emulator claim follows.

## References

Memotech's *MTX Series BASIC Tutor, Reference and Operator's Manual*, USR reference (return value in BC); Memotech's *MTX Video Memory Mapping*, VDP port sections; MTX service/hardware notes for the keyboard drive/sense wiring. This refines the existing stock-firmware input-loop's qualified Space mapping; it does not replace its firmware with a synthetic ROM.

The pinned native observer enters MTX source with separately phased modifier/key presses and a settling interval after each line. Bulk `type_string` acknowledgement alone did not establish that the interpreter received the same program. Exact loaded-byte and observed-screen guards remain required; this is an input-delivery observation, not a finding that valid FOR syntax is unsupported.
