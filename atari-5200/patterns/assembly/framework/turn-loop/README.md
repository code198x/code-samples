# Atari 5200: keep the picture running while turns wait

Build with `make` using Asm198x, then start `build/demo.bin`.
Qualified startup: NTSC 32 KiB cartridge handed over by the identified 5200 BIOS. No original hardware or PAL claim.

## Reuse

Copy `cross-platform/patterns/framework/atari-turn-loops/turn.inc` and `edge-filter.inc` together. Define T as
seven disjoint RAM bytes ($1000–$1006 in this caller), clear decimal mode, and call
init_turn with A=initial counter. It initialises previous/current samples,
service count and acceptance to zero, and step to one. Set T+5 to another byte
step after init if needed.

Pass the same active-high primary-button mask convention in A to sample_turn.
T+6 returns 1 for newly pressed bits, 0 for held/released/idle. T+0 adds T+5 once
on acceptance, modulo 256. T+1 remembers every sample; T+4 is current scratch.
Read acceptance before another sample replaces it. With multiple buttons, any
new bit causes one update, not one update per bit. Zero step still accepts.

Call service_tick exactly once per serviced field. T+2/3 is its little-endian
16-bit count, wrapping at 65536; it is not a turn count or a deadline.
Init/sample change A/P; service_tick changes P only. X/Y are preserved. Each
JSR uses two stack bytes, plus caller/interrupt depth; no nested routine calls.
Shared state is non-re-entrant. The routines touch no hardware or interrupt state.
Compiled routine: 77 bytes for this allocation, excluding caller and padding.
The other addressing mode may produce a different size and cost.

## Caller and timing ownership

See demo.asm for complete machine-specific setup. The 2600 emits its picture
using a 262-line NTSC schedule; all useful work must fit the selected blanking
slots. 5200 uses VCOUNT bit 7 and a BIOS handover; MARIA on the 7800 uses MSTAT
bit 7 with empty display lists and reset without BIOS authentication. Polling
accepts fresh intervals; it does not store missed fields or budget arbitrary work.
The routines are shared because the rule state agrees, not because the machines
share video timing. The caller's reset stack, video ownership, guards and display
structures are additional resources. Do not merge this takeover with an ISR or
OS service that also owns the interfaces.

## Customise and diagnose

Replace settings.inc with customise.inc and rebuild: counter 0/2/4, with feedback
mask 2 so the next bit still changes the picture. No extra code/context bytes.
wrap.inc exercises 254/255/0 with step one. Restore settings.inc for the default.

The deliberately broken shared mistakes/held-as-press.inc replaces edge-filter.inc.
It repeats progress while held. Restore edge-filter.inc to repair it.
mistakes/no-wait.inc replaces frame.inc and counts CPU iterations instead of accepted fields; restore frame.inc.
Faults are isolated fixtures, not part of the recommended routine. A still
cannot prove rate or television instability; use the retained counter/period
observations. Both repairs have their own cold runs and match the good executable.

## Reproduce

```sh
python3 scripts/verify-atari-turn-loops.py --tools /path/to/pinned/binaries --only atari-5200
python3 scripts/check-atari-turn-records.py
python3 -m unittest discover -s scripts -p test_atari_turn_records.py -v
```

The shared toolchain.json identifies release archives, executable hashes and
producer source locks. Supply the identified BIOS yourself on 5200; none is
committed. verification/results.json binds maintained assembly/build inputs,
observer code, native executable identities and 28 complete native captures.
Seven runs check idle/press/hold/release, customisation, byte wrap, two faults
and their repairs. CI checks retained evidence; only the native verifier executes.
These are configuration-specific observations, not every facility of an emulator.
