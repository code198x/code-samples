# Gloaming prototype — gate scripts

The winnability-gate verification suite for the reshaped prototype
(`../gloaming.asm`). Run with:

```
emu198x-spectrum --headless --script <name>.script.json
```

Artefacts (screenshots, WAVs) land in `artefacts/` (gitignored output).

| Script | Proves |
|---|---|
| `won.script.json` | Win gate: engineered eighth lamp → THE NIGHT IS HELD, then Space → dusk 2 with lives carried (the deepening) |
| `dawn.script.json` | The true ending: fifth watch's win → DAWN BREAKS (chime + sweep + fanfare), then Space → title with the full longest-night pip row |
| `sting.script.json` | Loss gate: one life, wisp adjacent, one step → NIGHT FALLS |
| `probe.script.json` | Menace: no input after Space — the idle lamplighter must be hunted down to NIGHT FALLS |
| `bells.script.json` | Audio: 10s of the title dusk bells |
| `dawnwav.script.json` | Audio: the dawn sequence (chime → sweep → fanfare) |

**Poke addresses are build-specific.** The engineered setups poke
`lit_count`, `lives`, `draught_col/row/timer`, and `dusk` by absolute
address, and code changes shift the variable block. After any edit to
`gloaming.asm`, assemble with a symbol file and re-derive:

```
pasmonext --sna gloaming.asm gloaming.sna gloaming.sym
```

Addresses as checked in (2026-07-02): `lit_count` $8A02, `lives` $8A03,
`draught_col` $8A04, `draught_row` $8A05, `draught_timer` $8A09,
`dusk` $8A0B.

**Input timing:** Space taps on the *title* hold 30 frames (the dusk
bells poll between cells — a short press can fall inside a bell).
Space taps on end screens hold 4 frames only — a longer hold outlives
the title's 25-frame input lock and starts an unwanted run.

Human capstone: unassisted title-to-DAWN-BREAKS run completed by Steve,
2026-07-02 — the gate's human half.

## Module-1 cut (`gloaming-m1.asm`)

The tiny-first-game cut, derived 2026-07-02 from the full prototype by
subtraction (no pools/tendril/queue/watches/dawn/tune). Its own suite:

| Script | Proves |
|---|---|
| `m1-won.script.json` | Win gate: eighth lamp → THE NIGHT IS HELD (final), Space → title with the best-lives pip row |
| `m1-sting.script.json` | Loss gate: one life, one step → NIGHT FALLS |
| `m1-probe.script.json` | Menace: idle player hunted to NIGHT FALLS at pace 16 |

m1 addresses (2026-07-02, post `unlight_pip` strip): `lit_count` $8605,
`lives` $8606, `best_lives` $8607, `draught_col` $8608,
`draught_row` $8609, `draught_timer` $860A. The boot chime blocks ~2s — openings wait 160
frames before the Space tap; the plain title polls every frame, so
short taps are safe everywhere in m1.
