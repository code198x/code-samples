# C02a: NES introduction timing corrections

Units 09 and 10 keep PPUMASK zero: both are rendering-disabled palette
experiments. Unit 09 enables VBlank NMI and updates a byte counter; unit 10
leaves NMI disabled and polls controller A continuously. Their lessons now
state that boundary instead of prescribing all game work in NMI or treating
an entire frame as a graphics-transfer window.

The unit 09 handler now saves/restores A with PHA/PLA. CPU interrupt entry
saves PC/status, not A/X/Y. The old idle JMP loop did not consume A, so its
visible output hid that clobber. X/Y are untouched by this handler. The change
makes its preservation contract explicit without adding a game scheduler.
Unit 10's executable bytes are unchanged; its source gains two scope comments.

## Build and execute

From either unit directory, `make` uses Asm198x's ca65 dialect. The lesson
commands now match these existing Makefiles. The checked-in ROM is rebuilt
when the source changes. With the native NES verifier available, run from the
code-samples repository:

```sh
python3 nintendo-entertainment-system/assembly/meet-the-machine/verification/timing.py \
  --emulator /path/to/emu198x-nes \
  --output /tmp/nes-introduction-timing
```

First verified on 22 September 2026 with an unreleased Emu198x NES build
reporting 0.25.0. Re-recorded on 10 November 2026 with the Asm198x 0.0.75 and
Emu198x 0.45.1 releases, NTSC, on macOS Apple silicon: every observation is
identical. From Emu198x 0.46.1 the programs' frame phase after power-on moves by one
frame, so unit 09's palette entries read $03–$06 rather than $04–$07 and the five-shift
colour changes land a frame later (29/61/93 rather than 28/60/92); the record
stays on 0.45.1 until emu198x#2349 is resolved. `results.json` names the tools by
release and lists the three programs the machine runs; CI rebuilds them with
the units' Makefiles and compares their bytes. The verifier checks:

- Unit 09: rendering disabled, NMI enabled; return to the idle instruction after
  four successive frame updates; A, X, Y, status and stack pointer unchanged
  at that observation point; four different successive palette entries.
- Unit 10: rendering and NMI disabled; controller 1 A released/held/released
  produces palette entries $16/$2A/$16. Input uses the runtime's logical
  `Button { port: 1, name: "a" }` contract, not a native keyboard binding.

These are emulator register/palette checks. They do not establish an exact
hardware NMI latency, a universal transfer budget, native controller response,
or original-hardware accuracy. The short handler has no loop or wait. Future
rendered games must budget their actual transfer workload, including interrupt
and preservation overhead; this experiment does not prove that workload fits.

## Source review

The hardware explanations were checked against NESdev's public hardware
research: [NMI](https://www.nesdev.org/wiki/NMI),
[CPU interrupts](https://www.nesdev.org/wiki/CPU_interrupts),
[PPU registers](https://www.nesdev.org/wiki/PPU_registers),
[PPU rendering](https://www.nesdev.org/wiki/PPU_rendering) and
[Standard controller](https://www.nesdev.org/wiki/Standard_controller).
The public pages returned HTTP 403 during this review, so archived copies
were inspected. These are community hardware research, not manufacturer manuals.

The prose distinguishes NMI's edge-triggered notification from handler entry,
PPUSTATUS's status/latch side effects from a required interrupt acknowledgement,
and SEI's IRQ masking from NMI. The slower-colour exercise corrects three shifts
versus five: division by 32 gives eight values from a byte counter, with a
32-update hold. It does not change the display rate or promise half a second
on every region. The old extra-main-loop palette-write exercise was removed
because it invited shared PPU-latch interference after NMI had been enabled.

Later Dash music/scheduling work remains planned. No shared-buffer framework,
advanced interrupt engine or new graphics architecture is introduced here.

The verifier also assembles the exact five-shift variation in its output
directory, checks that values stay in 0–7 and observes changes 32 frames apart
over 100 frames. This requires Asm198x on PATH (or `--assembler /path/to/asm198x`).
Both lessons compile as MDX; curriculum-route and template-whitespace checks
pass. Unit 09's timing section was visually reviewed in the local Chrome preview.
