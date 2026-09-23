# Dash unit 14: NMI budget

C02d corrects the explanation; the game source and ROM are unchanged.
Baseline: code-samples revision `8efbde958431b9e8c35ebca3a6fd848f4c134f61`,
`unit-14/dash.asm` and `dash.nes`. Exact file hashes and tool identity are in
`results.json`. The checked-in ROM is the recovery copy; the runner rebuilds
into a separate output directory and requires byte-for-byte agreement.

## Reproduce

From code-samples, with Asm198x and the native Emu198x NES executable available:

```sh
python3 nintendo-entertainment-system/assembly/dash/unit-14/verification/check.py \
  --emulator /path/to/emu198x-nes --output /tmp/dash-nmi-budget
```

Verified 22 September 2026: Asm198x 0.0.58, Emu198x NES 0.25.0, NTSC NROM,
rendering enabled, DMC disabled. The runner reuses the introduction's small MCP
client. It boots the unchanged ROM for five frames, stops at NMI entry and sets
zero-page game_over ($0B) and game_over_drawn ($0C) for three controlled cases.
These are diagnostic state injections, not evidence of a natural losing run.

The boundary is first PHA at $83BA through completed RTI at $8444. Four entries
per case give the following elapsed guest CPU cycles:

| Case | Instructions | DMA stall | Measured total |
| --- | ---: | ---: | ---: |
| Playing | 119 | 513–514 | 632–633 |
| First game-over message | 193 | 513–514 | 706–707 |
| Message already drawn | 124 | 513–514 | 637–638 |

Each instruction is stepped and compared against its opcode cost, including
branch direction and page crossing. Taken branches at $83F2 and $83F6 cross to
$8433 and take four cycles. DMA appears in the step of BIT $2002 after STA
$4014: the 513/514-cycle stall is additional to BIT's four cycles. The register
write initiating DMA still has its ordinary instruction cost.

First-message breakdown: save A/X/Y 13; OAM setup/write 12; HUD including latch
read, address setup and arithmetic 50; two flag checks 10; message address 12;
nine tile pairs 54; mark drawn 5; scroll restore 10; notify main loop 5;
restore registers and RTI 22. Total 193, plus DMA.

Measurements use machine.master_clock (PPU dots, divided by three for NTSC),
which advances during DMA. cpu.total_cycles in this emulator freezes during
DMA and would undercount the deadline cost. Host elapsed time is not measured.
The runner also checks A/X/Y preservation, balanced handler stack use, two or
11 PPUDATA writes, and return on scanlines 241–260. The deadline is completion
before pre-render scanline 261; every observed return meets it.

This boundary excludes the interrupted instruction and seven-cycle interrupt
entry. Those still consume time between notification and completion. Counts
are observations of this binary and these paths, not a universal safe budget,
a full latency measurement, PAL evidence or original-hardware testing. No
new in-game instrumentation is inserted. The learner prediction exercise has
not yet had a separate learner trial.

## Sources

NESdev's community hardware research supplies the timing contract:
[DMA](https://www.nesdev.org/wiki/DMA),
[the frame and NMIs](https://www.nesdev.org/wiki/The_frame_and_NMIs),
[6502 cycle times](https://www.nesdev.org/wiki/6502_cycle_times), and
[CPU interrupts](https://www.nesdev.org/wiki/CPU_interrupts).
Instruction addresses come from the assembled ROM, not estimated source layout.
DMC DMA can extend OAM stalls; this game does not enable it. Adding work or
changing layout requires a new count and deadline check.
