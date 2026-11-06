# Byte check instead of text pins

**Status:** Proposed 2026-11-06. Step 1 of
[`2026-11-06-evidence-that-pays.md`](2026-11-06-evidence-that-pays.md).

Checkers stop failing when the text of a source or a script changes. Each
checker rebuilds its records' programs with the assembler the record pins
and fails only when the bytes differ. One shared module does the rebuild,
and the checkers move to it in eight batches, one pull request each.
Existing records are not edited: their `sources` fields stay as provenance
until each family next re-records.

## What the checkers do today

Measured at `9c5ade15`: 124 `scripts/check-*.py`, each read with its
recorder, build files, unit test and one record. Not in this survey: the
pattern-local `verification/*.py` scripts (142 use digests, four run in
CI). Batch 8 surveys them the same way before it migrates them.

| What | Checkers |
|---|---|
| Compare some file's text digest | 122 (two compare none) |
| … by recomputing the whole `sources` map from a path list | 69 |
| … by re-hashing each path the record lists | 53 |
| … by named fields (`source_sha256`, `observer_sha256`, script digests, inventory files such as `bindings.json`) | 67 |
| Pin at least one file under `scripts/` | 121 |
| Have an altered-evidence control that tampers a text digest | 122 |
| Delegate the check to another checker | 4 (three wrap `check-dragon-assembly-deadlines.py`, one wraps `check-ace-object-pool.py`) |

How the records name the program (one class per checker):

| Program identity in the record | Checkers |
|---|---|
| The program's bytes (`program_zlib`, `loaded_program`, `program_bytes`) | 51 |
| Only its digest (`program_sha256`, `binary_sha256`, configuration `programs`) | 42 |
| Only bytes read back from the emulated machine's memory | 11 |
| Nothing: the program is text the machine is given | 20 |

How the programs are made, which sets the batches below:

| Built by | Checkers | Record files |
|---|---|---|
| Asm198x through a pattern `Makefile` | 13 | 447 |
| Asm198x through a `build.py` (local or shared) | 24 | 376 |
| Asm198x run by the recorder itself, often on generated source | 23 | 53 |
| build198x (C64 PRG, Spectrum TAP), with the BBC Micro route typed in | 24 | 985 |
| BASIC or FORTH typed into the machine's ROM | 15 | 71 |
| AMOS or Blitz source imported and run inside the emulated Amiga | 13 | 59 |
| Several of the above, one per machine route | 7 | 161 |
| Inventories over other families' records | 3 | 76 |
| No retained record or no text pin | 2 | 1 |

Assembler pins, by the binary digest records and configurations name:
Asm198x 0.0.72 (438 pattern folders), 0.0.71 (105), 0.0.74 (30), 0.0.65
(4), 0.0.64 and 0.0.58 (one NES folder), and one digest that matches no
release (Spectrum `profile-a-routine`, probably a local build). BASIC
records pin build198x 0.2.9 (658 folders); AMOS records pin build198x-adf
0.2.13, which packs the source onto the disk the emulated Amiga reads.

### Pattern-local verification scripts

Surveyed for batch 8 at `124205dc`: every tracked `*/verification/*.py`
(186), with the tools each runs, what cites it, and what imports it.
Steve's ruling: no script may sit outside CI. Each one is migrated (byte
check plus a CI job) or culled. **Migrate** applies when a lesson, README
or pattern page cites the script, or a CI checker reads its record.
**Cull** needs a positive signal. **Unsure** is listed and left alone.

A *check* reads retained records and runs no tools. A *recorder* runs
Asm198x and an Emu198x emulator, and writes records. A *helper* is a
module that recorders import.

| # | Scripts | Kind | Cited or used by | Decision |
|---|---|---|---|---|
| P1 | `cross-platform/patterns/physics/aabb-collision/verification/verify.py` | check, fresh oracle run | README, website, CI | In CI already; no text pin to replace |
| P2 | `cross-platform/patterns/rendering/pre-shifted-sprites/verification/verify.py` | check | README, CI | In CI already |
| P3 | NES `square-wave` and Spectrum `bitmap-addressing` `verify.py` (2) | recorder; Asm198x 0.0.65 and Emu198x releases | README, website, CI | In CI already: CI runs them fresh. `check-pattern-evidence.py` checks their retained records (see inventories) |
| P4 | C64 `sid-note-trigger`, `joystick-reading`, `sprite-movement-bounds`, `hardware-sprites`, `raster-splits`, `sprite-multiplexing` `verify.py` (6) | recorder; Asm198x, ACME as oracle, Emu198x and VICE | README and website; five via their `Makefile` | Migrate: a CI byte check of each record (question 1). Pins are Asm198x 0.0.58 and 0.0.64, released but without source locks |
| P5 | Spectrum `sound-beep` `verify.py` | recorder; Asm198x, Pasmo as oracle | README, website | Migrate, as P4 |
| P6 | Amiga `playing-a-sample` `test_verify.py` | check (unit test, no tools) | README | Migrate: CI can run it now |
| P7 | Amiga `playing-a-sample` `verify.py` | recorder; its failed-run record pins build198x `097892fa…`, which matches no release | README, website, `pattern-evidence.json` | Unsure: rule 3, for Steve |
| P8 | Spectrum `profile-a-routine` `run_checks.py` | recorder; `checks.json` pins Asm198x `886af887…`, which matches no release | README, website | Unsure: rule 3, for Steve |
| C1 | Spectrum BASIC `audit.py` (21) | check; 21 call `source-lineage` | unit README | Migrate (question 2). Three need `--evidence` |
| C2 | Spectrum BASIC `derive.py` (7), `model.py` (4), `lessons.py`, `level.py`, `deduction.py`, `assets.py`, `audio_separation.py`, `pitches.py` | check | unit README | Migrate. Two take WAV inputs; `lessons.py` calls `source-lineage` |
| C3 | Spectrum BASIC recorders (103: `build.py` 23, `check.py` 21, `verify.py` 10, others) | recorder; Spectrum ROM keyboard entry | unit README (94), website (7) | Migrate (question 1) |
| C4 | Spectrum BASIC helpers (19: `entry.py` 15, `tape.py`, `picture.py`, `observe.py`, `state.py`) | helper | imported by the C3 recorders | Moves with C3 |
| C5 | Spectrum assembly `meteor-storm` `model.py` and `teaching_order.py` | check | unit README, website | Migrate: CI can run them now |
| C6 | Spectrum assembly recorders (7), including `serve-preview.py` | recorder; Asm198x, Pasmo as oracle (4), build198x (1) | unit README, website | Migrate (question 1). `serve-preview.py` serves port 1987 to the `browser.mjs` and `profile*.mjs` recorders |
| C7 | NES `dash` `unit-11` and `unit-14` `check.py`, `meet-the-machine` `timing.py` | recorder; Asm198x | their own `verification/README.md` | Migrate (question 1) |

- **No culls.** Every script either is cited by a README or website page
  or is imported or served to a recorder. The 15 scripts that nothing cites
  by path are helpers:
  - 13 `entry.py` modules and Touchdown's `state.py`, imported by their
    recorders;
  - `serve-preview.py`, the server the `meet-assembly` browser recorders
    load. `git grep serve-preview` finds nothing in code-samples, the
    website or Code198x/docs; its users reach it on port 1987.

  The `.mjs` recorders beside `serve-preview.py` are outside this
  `*.py` survey.
- **A stale record found on the way.** `the-caverns/prototype/verification/model.py`
  rewrites `evidence/model.json`'s `source_sha256` from `27ca75ef…` to
  `dc780a9b…`. The other 35 checks that run without arguments pass and
  leave their committed files unchanged.
- **Third-party assemblers are oracles, not producers:** ACME
  `7be6afb147f75c974a48a0540cdb8affc0760ed94bed4d822d95c7e8ee4bb35c`
  and Pasmo
  `e9628f5c32f3c74a963c649781e6cb87e9eaeb4bbfe7b52d3de27f4986bbf136`.
  Their digests stay as provenance; no check fails because one is not a
  family release.
- **Rule 3, for Steve.** These records are pinned to a tool that matches
  no release:
  - Spectrum `profile-a-routine` `verification/checks.json`: Asm198x
    `886af887f5b26b3adf65947d79a3dd9c637cd7b822cd6f86cc68350cbc14c760`.
  - Spectrum `basic/input/two-word-parser/verification/results.json` and
    Amiga `playing-a-sample/verification/runs/2026-10-15-failed.json`:
    build198x
    `097892fa8ed3ac02ba60e85204712dc92ec3e03b18bbfe4c55806c80c33b2303`,
    a local `target/release` build.
  - Curriculum unit captures (`*/unit-*/capture/proof.manifest.json`):
    seven build executables (`fb4e7fc3…`, `ab843a7f…`, `c465a1cb…`,
    `d6ba0cef…`, `80ecfa7a…`, `a801e6bc…`, `2fd5c2a3…`). No script or
    checker reads them.
- **Released but unlocked:** `a769808c…` is Asm198x 0.0.58 and `2286f8ba…`
  is Asm198x 0.0.64. The C64 joystick, sprite and raster records and the
  NES square-wave record pin them; `add-release` reads such releases from
  their binaries.

#### Questions batch 8 cannot answer

1. **Recorders in CI.** Recorders type listings through an emulated ROM
   keyboard. They need Emu198x and, on the C64 and Amiga, firmware that CI
   does not hold.
   - (a) *Recommended:* CI checks each recorder's retained records, with
     the program rebuilt or regenerated, the byte check, and the
     retained-evidence checks. The recorder stays hand-run, as
     `scripts/verify-*.py` recorders are.
   - (b) CI runs the recorders fresh, as P3 already does. This is possible
     for the Spectrum and NES, at several emulated minutes per Spectrum
     listing across 103 recorders, and impossible for the C64 and Amiga
     without their firmware.
2. **Source lineage against rule 2.** The C1 audits and `lessons.py`
   accept evidence recorded on an earlier text through
   `sinclair-zx-spectrum/basic/source-lineage/lineage.json`.
   `space-only` links remove stored spaces; `renamed-variable` links
   rename a variable. Under rule 2 both change the typed program, so the
   byte check would fail those units. Choose one:
   - keep lineage as a curriculum exception to rule 2;
   - retire it and re-record the linked units.
3. **Inventories with no owner.**
   - `docs/capability-coverage.json` and `docs/probe-coverage.json` list
     60 records. Only the four Dragon and Ace records have an owning
     checker (`check-dragon-ace-loops.py`).
   - The 26 typed-route records keep only source digests, so the typed
     demo can be compared under rule 2.
   - The 30 assembly records keep `binary_sha256` but pin no assembler.
   - `check-pattern-evidence.py` is the only checker for its 16 records.
     Of these, eight routine-audit and two parser records pin no tool,
     and `parser-basic` pins the unreleased `097892fa…`.

   "Leave staleness to the owning checker" would leave these with none.
   Choose one:
   - the inventories become the owners: typed routes compare text, and
     assembly records are re-recorded with the newest Asm198x, as for
     fixed characters;
   - they keep their source digests until each family is re-recorded.

## The shared module

`scripts/evidence_bytes.py`, added by batch 1:

- `Build(cwd, command, outputs, env)`: one run of the family's own build.
  `{asm198x}` in `command` or `env` becomes the pinned assembler's path.
- `require_program(build, output, pin, recorded=… | recorded_sha256=…)`:
  rebuild and compare with the bytes the record keeps, or with its digest
  when it keeps only that. A mismatch raises `AssertionError("Program bytes
  differ from the record: …")`, naming the first differing offset when the
  record keeps the bytes.
- `rebuild(build, pin)`: deletes each output first, so a build that writes
  nothing can't pass on an old file; fails on a non-zero exit; keeps the
  result for the life of the process, so 107 altered-evidence controls cost
  one build.
- `make(folder, outputs)`: the pattern-Makefile case, `make -B
  ASM198X={asm198x}`.
- `assembler(pin)`: a verified binary of the pinned release for this host.

## Finding and rebuilding a record's program

The checker knows its family; the module doesn't guess. Each checker builds
its `Build` from the **same entry point its recorder uses**, never a copy of
its arguments:

- a pattern `Makefile`: `E.make(folder, outputs)`;
- a `build.py` (local or shared): `python build.py <variant>` with
  `ASM198X={asm198x}`;
- a recorder that runs Asm198x itself, often on Python-generated source:
  move the generator and the argument list into a function the recorder
  and the checker both call, in the batch that migrates it, so they can't
  drift.

The pin is the assembler digest the record or its `configuration.json`
already names. The checker compares with the program bytes the record keeps
(`program_zlib`, `loaded_program`, `program_bytes`) when it has them, and
with `program_sha256`/`binary_sha256` when it doesn't. A record that holds
several programs (character-regions has 18 per machine) checks each.

## Getting the pinned assembler

- The record pins a binary digest, usually the `aarch64-apple-darwin` one.
  `scripts/evidence-assemblers.json` maps each release to every target's archive and binary digests, taken
  from the release's own `*-source-lock.json`, so the same release can be
  fetched for any host. `evidence_bytes.py add-release <tag>` writes an
  entry and refuses a release whose targets came from different commits.
  Releases before 0.0.67 publish no source locks; for those, the batch that
  needs them extends `add-release` to take the archive digest from the
  release's `.sha256` and hash the extracted binary.
- `assembler(pin)` looks in `$CODE198X_TOOLS` (default
  `~/.cache/code198x/tools/<tag>/<target>/asm198x`), downloads the archive
  from the GitHub release if it's missing, and checks the archive and the
  binary against the table before running anything. Locally that is one
  download per release; in CI, each job downloads what it uses (about 3 MB
  per release). If downloads prove flaky, add `actions/cache` keyed on the
  table.
- A missing tool, an unknown pin or a failed download fails the check. It
  never skips.
- Step 2 changes only where `assembler()` finds the release: the root
  `toolchain.json` pin replaces the per-record pin, and the pin-move replay
  catches any bytes that differ under the new release.

Rebuilding with the release the record pins, not the latest, is what makes
the step's own check work: Asm198x 0.0.75 refuses `ptr=$0070` with
`sta (ptr),y`, while 0.0.74, which those records pin, builds it to the same
bytes as `ptr=$70`.

## Programs the host can't rebuild

**Rule:** the program is the bytes the machine is given.

1. **The host builds a binary** (Asm198x, build198x, a Python generator):
   the checker rebuilds it and compares bytes.
2. **The machine is given text** (BASIC or FORTH typed in, AMOS or Blitz
   source imported and run or compiled inside the emulated Amiga): the text
   is the program. The checker regenerates it the way the recorder does (for
   example the combined `.bas` listing) and compares it with the record's
   digest of that text. A comment or `REM` in that text changes what the
   machine is given, so it still makes the record stale. A change to a
   script, an oracle or another family's file does not.
3. **The host builds a binary with a tool the module can't fetch** (a pin
   that matches no release): the checker keeps comparing the record's
   program inputs, its `sources` entries outside `scripts/`, and stops
   comparing script digests. It prints `text-pinned: <reason>` on every
   run, and this plan lists each one. It moves to rule 1 when the family
   re-records with a released tool. No surveyed checker needs it today:
   the one unreleased pin (Spectrum `profile-a-routine`) is read by no
   `check-*.py`.

Every checker uses one of the three; none drops its staleness check.

## Altered-evidence controls

A control that tampers only `sources` or a script digest tests a pin this
step removes. A tampered digest can't be told from a changed file, so it can
no longer be rejected. Each such control (122 checkers have one) is
replaced by a **forged program** control: the record claims other
bytes consistently (program digest, loaded bytes and configuration agree),
which only the rebuild can reject, and the control requires the rejection
to be the byte check's message. Each family also gets a test that rewriting
every `sources` digest is accepted. Every other control stays as it is, and
a checker's own count, such as "107 altered-evidence controls", stays the
same.

## Batches

Each batch is one pull request with CI green. Counts are checkers.

| # | Batch | Checkers | Needs |
|---|---|---|---|
| 1 | **The module and the assembly object pools:** `check-object-pool.py` (C64, NES; Makefile, Asm198x 0.0.72) and `check-additional-object-pools.py` (BBC Micro, Atari 800XL, CPC, Dragon 32; shared `build.py`, 0.0.74). | 2 | — |
| 2 | **Makefile families:** game-rules, gamekit, gameplay-patterns, nightone, nighttwo, playtools, pools-and-states, seeded-random, toolkit, worldkit, tia-maria, xl-coleco. Teaches the module build198x, whose ADFs these Amiga routes record. Staged-copy recorders (tia-maria, xl-coleco) rebuild from the same staged copy. Inventory files such as `bindings.json` stop comparing source and script entries; their record-file entries stay. | 12 | build198x in the module |
| 3 | **Shared `build.py` families:** the rendering families (character, glyph, text, region, tile and bitmap patterns) and the rectangle-overlap ports. | 23 | — |
| 4 | **Recorder-built programs:** the deadlines, input-edges, map and sprite recorders. Each recorder's source generator and argument list move into a function the checker also calls. | 23 | — |
| 4b | **Unassigned and re-recorded:** `check-c64-rom-font.py`, whose recorder's build moves into a function the checker calls. The sprite lifecycle, clipping and phases checkers and `check-rendering-evidence.py`: their records kept no program identity, so each recorder gains a build-only `programs()` and the records are re-recorded, with the tools they pin, to add `fixture_programs` (and `caller_programs` where the recorder builds callers with their Makefiles). `check-fixed-characters.py` follows in its own pull request: its records pinned no assembler, so they are re-recorded with Asm198x 0.0.75 to name one. | 6 | build198x-adf in the module |
| 5 | **build198x BASIC:** the 23 `check-basic-*` families and the C64 adventure parser. C64 and Spectrum routes rebuild with build198x 0.2.9; the BBC Micro route is typed (rule 2). | 24 | rule 2 |
| 6 | **Typed BASIC and FORTH:** the Ace FORTH families, the stock-ROM BASIC deadlines and maps, and `check-basic-turn-records.py` (Acorn Atom and Amstrad CPC BASIC typed into stock ROM). Checkers compare the typed text through `evidence_bytes.require_typed()`, whose `Typed program differs` message the forged-program controls require. | 16 | rule 2 |
| 7 | **AMOS and Blitz:** the AMOS deadline, game flow (and its signed minimum), map queries and object pool (with its age, boundaries and extremes passes), and the Blitz deadline, game flow, map queries and object pool. Each compares the regenerated imported or compiled source text through `require_typed()`. `check-amiga-command-loops.py`, whose routes include AMOS and Blitz, is in batch 8. | 12 | rule 2 |
| 8 | **Mixed routes:** atari-turn-records, loop-language, commodore-command-loops, msx-gameboy, aquarius-mtx, dragon-ace and amiga-command-loops (code198x/code-samples#443); column-evidence and tilemaps (#444). Each route is judged by its own rule. | 9 | rule 2, build198x-adf 0.2.13 |
| 8b | **Inventories and pattern-local scripts:** capability-coverage, probe-coverage and pattern-evidence, and the verification scripts in the table above. These wait on questions 1 to 3 and the rule 3 list. | 3 + 186 scripts | Steve's rulings |

The two checkers with no text pin (`check-c64-starters.py`,
`check-pattern-library-prototype.py`) need no change.

## How each batch is verified

- Every migrated checker and its unit tests pass locally and in CI.
- For each family: a comment-only edit to one source passes; an operand
  change fails with `Program bytes differ`; an edit to a script its records
  pin passes; a tampered observation is still rejected; the forged-program
  control is rejected by the byte check.
- `git diff --stat origin/main -- '*/verification/*'` is empty: no record
  is edited.
- The migrated checkers contain no comparison of `sources` or script
  digests, except the rule 3 list.
- **Batch 1 carries the step's check:** reverting code198x/code-samples#424
  (`ptr=$0070` on the BBC Micro, `ptr=$00cb` on the Atari 800XL) still
  passes, because Asm198x 0.0.74 builds both to the same bytes, while
  changing an operand fails. `scripts/test_evidence_bytes.py` keeps both as
  tests, built from copies of the real sources.

## Decisions for Steve

None blocks batch 1, whose programs are all host-built by released tools.

- **Rule 2:** *agreed 2026-11-06.* Typed, imported and in-machine-compiled
  programs keep their text as the program, so a comment in BASIC, FORTH,
  AMOS or Blitz source still needs a re-record. A `REM` is in the machine's
  memory and in its `LIST`, so editing it does change the program.
- **Each record rebuilds with the release it pins:** *agreed 2026-11-06*,
  until step 2's root pin. Step 2 then changes only `assembler()`, and the
  replay re-records whatever differs.
- **Records without program identity are re-recorded under rule 1:**
  *agreed 2026-11-06*, for batch 4b. The sprite lifecycle, clipping and
  phases records and the rendering-families record kept sources, observer
  and capture digests but no program bytes or digest, so there was nothing
  to rebuild against. They were re-recorded with the same Asm198x and
  build198x releases and emulators they already pin, adding only program
  digests, rather than given a rule 3 exception. Every observation, count,
  control and capture came out identical to the committed record; only
  `fixture_programs`, `caller_programs` and the provenance digests of the
  edited recorder scripts changed. Batch 4b, the fixed-characters
  follow-up and the BASIC rendering follow-up below are the only changes in
  this plan that edit records.
- **Records without an assembler pin are re-recorded with the newest
  release:** *agreed 2026-11-06*, for `check-fixed-characters.py`. Its
  records kept each driver's `fixture_sha256` but named no assembler, so no
  release could be chosen for the rebuild. They were re-recorded with
  Asm198x 0.0.75, the newest release, and the Emu198x 0.48.3 emulators they
  pin, and now name it in `assembler_sha256`. Every fixture, memory dump,
  flag, capture and pixel result came out identical; only the new pin and
  the provenance digest of the edited recorder changed. The ZX80 and ZX81
  callers are typed in, so their `caller.bas` text stays part of the
  program (rule 2).
- **Generated BASIC rendering callers are regenerated; the Spectrum's
  tapes are re-recorded under rule 1:** *agreed 2026-11-06*, for
  `check-basic-rendering.py`. Its callers are written by generators and
  were retained, so the three generators now produce each caller without
  an emulator and the checker regenerates and compares every one: by text
  on the typed routes (rule 2), and on the Spectrum by rebuilding its tape
  with the release the record names, build198x 0.2.13 (`lint --fix`, then
  tokenise). Before any record changed, the generators reproduced all 117
  retained callers byte for byte. The three Spectrum records, which kept no
  tape identity, were re-recorded with that pipeline and their pinned
  Emu198x 0.44.1 emulator to add `tap_sha256`; every observation, capture
  and caller came out identical, and only the new digests and the edited
  scripts' provenance changed. Rule 3 stays for unreleased tools only.
- **Rule 3:** keeping a text pin, without scripts, for programs built by an
  unreleased tool. The alternative is to re-record those families with a
  released Asm198x first. Batch 8's survey found three; see the rule 3
  list under the pattern-local scripts.
