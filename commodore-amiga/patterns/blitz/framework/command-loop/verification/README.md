# Native command-loop verification: BLITZ

Blitz BASIC 2.10 release / Ted 1.1, compiled in the original editor. Released Emu198x v0.44.1; PAL A1200, stock 2 MiB chip RAM, no fast RAM. Runtime, firmware, source, phase, observer and capture identities are in results.json. This is configuration-specific native execution, not original-hardware conformance, every ROM/model or whole-game timing qualification. Neither language inherits the other's evidence.

## Observe the result

Six separately entered/imported programs share the same verified empty-editor boot checkpoint. No score/state injection, host BASIC interpreter or desired-result memory writes were used. Actual keyboard input drives A, X, A, then Q. The initial view is captured after 100 native fields of running/compiling. Each entry/compile completes before the behavioural sequence.

| Case | Initial → A → X → A |
| --- | --- |
| Working | 0 → 1 → 1 → 2 |
| Step three | 0 → 3 → 3 → 6 |
| Reset in loop, deliberately wrong | 0 → 1 → 0 → 1 |
| Repaired caller | 0 → 1 → 1 → 2 |
| Wrap | 254 → 255 → 255 → 0 |
| Nonzero state, step 255 | 100 → 99 → 99 → 98 |

The retained checker reads counter glyphs directly from each original RGBA PNG and compares them with an independent modulo-256 command model. It rejects unknown/absent glyphs, requesters, missing observations and source changes. Its fixed eight-row numeral masks were visually checked against the native font. Blank cells terminate a number; a counter is required. The two runtimes use distinct framebuffer positions and scaling. A rehashed capture showing the wrong initial value fails the negative control.

Each action is a delivered line, not an asserted physical edge. Edit$(1) requires Return and the operating-system console remains active; the original debugger window is visible in captures. Comments are omitted while typing; maintained executable statements are entered line by line, with observed character counts checked.

## Reproduce lawfully

Supply the matching firmware and runtime media; no licensed disks, ROMs, extracted runtime files or running snapshots are distributed. Use the released producer-locked emulator identified in the record. AMOS fixture creation uses released Build198x ADF 0.2.13. Source-only phase files retain the exact event sequence, including startup settling. They are a reproducible observed route, not a promise that the shortest possible UI sequence has been found.

The maintained runner is `scripts/replay-amiga-command-loops.py`. For AMOS, run `--prepare --builder /path/to/build198x-adf --output /fresh/run` first; this masters the Cases fixture directly from maintained source and generates only the two initial-state variants. For each replay supply `--language blitz --emulator /path/to/emu198x-amiga --kickstart /path/to/kickstart.rom --output /same/run` and the relevant `--amos`, or `--blitz` and `--blitz-libs`, media arguments. Phase names are `blitz-boot.json`, `blitz-drawer.json`, `blitz-pointer.json`, `blitz-open.json`, `blitz-ide.json`, `blitz-ide-later.json`, `blitz-blank.json`, `blitz-edit.json`, `blitz-empty.json`, `blitz-settled.json`, then one named `blitz-*-case.json`. Run cases sequentially or in independent sessions; they restore the empty-editor checkpoint. Keep snapshots private and disposable.

Phase execution checks tool errors, typed-character counts and completed native field runs. It prints “inspect the native captures”, not “passed”. Only observed program output justifies a behavioural pass. After a rerun, inspect the images and run `python scripts/check-amiga-command-loops.py` against the retained source/evidence record. CI rechecks retained evidence and failing controls; it does not boot licensed software.

## Failed paths retained as limits

Typing before the startup requester and disk loading settled dropped the opening statements. That partial source was discarded. Waiting until the native editor was visibly empty, then re-entering the complete statements, compiled and produced the observed counters. No emulator bug follows from the premature entry.

The repaired caller is the same maintained program as working; the wrong caller changes only the placement of the counter initialisation. Default display/console setup, runtime memory use, save/reload, original-hardware behaviour, minimum hardware and other compilers remain separate qualifications.

## Publication pixels and references

Raw 1536 × 576 frames remain untouched for verification. Published 768 × 576 PNGs remove only proven identical column pairs, retaining every unique colour sample. CI reconstructs each export and refuses unequal pairs.

Primary reference: [Blitz BASIC 2 original manual](https://www.retro-commodore.eu/files/downloads/amigamanuals-xiik.net/Applications/BlitzBasic%202%20-%20Manual-ENG.pdf), tutorial “Getting Input from the User” (printed page 21), and reference “Edit$”, “DefaultInput”, “DefaultOutput” (printed page 100). The runtime version is independently observed on the booted 2.10/Ted 1.1 splash.
