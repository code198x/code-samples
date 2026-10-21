# Two Atari machines, two drawing contracts

These are small reusable components, not ports of a fictitious universal
framebuffer. Start with the complete caller, then copy the include into a project
that can meet its memory and timing contracts.

| Contract | Atari 2600 TIA | Atari 7800 MARIA |
|---|---|---|
| Reusable work | Clear/set 20×24 half-playfield; opaque 5×7 stamps | Begin/append bounded direct 160A objects |
| Video owner | Fixed 192-line CPU kernel, field caller owns blanking | Caller owns RAM DLL/lists, palettes, DMA and publication |
| Granularity | Four colour clocks × eight lines per independent cell | Four 2-bit pixels/byte; one logical horizontal pixel per object position |
| Recurring cost | CPU must emit each line even for an unchanged picture | Headers and graphics consume DMA time, halting the CPU |
| Limits | Repeated/reflected half, scarce 128-byte RAM | Page-stepped rows, list capacity plus per-line bandwidth |

- [TIA component and caller](../../../../atari-2600/patterns/assembly/rendering/playfield-kernel/README.md)
- [MARIA component and caller](../../../../atari-7800/patterns/assembly/rendering/maria-objects/README.md)

## Reproduce

Use released native `asm198x` and both `emu198x-atari-*` binaries in one tools
directory. No firmware is required for these original reset callers.

```sh
python3 scripts/verify-tia-maria.py --tools /path/to/tools --output /path/to/evidence
python3 scripts/verify-tia-maria-bounds.py --tools /path/to/tools --output /path/to/bounds.json
python3 scripts/check-tia-maria-records.py
```

The fresh verifiers assemble in automatically cleaned temporary directories,
reach actual CPU call/field markers, compare the whole destination allocation
and every native capture pixel, and require completed faulty controls to fail.
The 2600 also measures native master-clock distance between field markers.
The bounds caller snapshots allocations around every rejected call; guards and
marker checks stop a crashed or incomplete call from counting as a rejection.

Retained records were made on macOS arm64 with Asm198x 0.0.71 and Emu198x 0.41.0.
Both samples also assemble with the website's pinned Asm198x 0.0.65. Tool archive
and executable hashes are retained in `verification/tools.json`. CI checks
retained source/image/observation bindings and corruption controls; it does not
claim a fresh emulator run. Pictures are original glyphs, no external assets.

This is bounded drawing evidence. It does not establish original-hardware
accuracy, every palette/video mode, live list publication or a maximum-load
benchmark. The maths follows directly from packing, grid division, mirroring,
zone offsets and finite work per raster; later high-level patterns can compose
these components without erasing those differences.

## Learn from a broken version

The `mistakes/` folders contain deliberately wrong fragments and their fixes,
indexed by `mistakes.json`. They are diagnostic material, not replacements for
the reusable includes. The fresh verifier substitutes the exact fragments into
a temporary caller, reaches its completion markers and checks a separately
predicted full frame before accepting the intended failure. It also executes
all six corrected fragments and requires the known-good output and timing.

The 2600 cases reverse PF0 masks, delay the visible writes and add one overscan
line. The last still looks normal: the 263-line field is exposed by the native
clock measurement. The delayed writes affect PF0 and PF1 at band transitions
in the left half; the repeated right half is ready in time.

The 7800 cases fetch too few bytes, discard the requested position and damage
the terminator. The terminator fixture plants a known third header and a second
valid terminator; it never relies on an uncontrolled RAM walk. An additional
retained too-wide control fetches an extra zero byte and changes the list even
though this picture stays identical. A clean-looking still is not proof of a
correct header or workload.

Sixteen native observations are retained: three normal/reflected examples,
seven broken controls and six repaired examples. Public gallery captures show
six selected faults with symptoms, causes and fixes. Full-frame PNGs are
unaltered; the normal working binaries and routine interfaces are unchanged.

## Make it your own

Both components have separate `customise/` callers and Makefiles. The TIA
example adds maze walls, an original arrow, foreground colour and repeated /
reflected views through the same kernel. The MARIA example changes the original
shape, byte width, placements and palette selection while retaining the same
static DMA ownership. The normal libraries/callers remain unchanged.

Fresh customisation verification:
`python3 scripts/verify-tia-maria-customise.py --tools /path/to/tools --output /path/to/output`.
Three additional native observations bind source, destination and full frame;
the TIA period remains 59736 colour clocks. The retained gate now checks nineteen
observations in total, and corruption tests include the new source and images.
Per-caller READMEs explain exact changes, work/storage costs and extensions that
need new verification. These variations deepen the same two entries.
