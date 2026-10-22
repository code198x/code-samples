# Native command-loop verification: AMOS

AMOS Professional 2.00, interpreted in its original editor. Released Emu198x v0.44.1; PAL A1200, stock 2 MiB chip RAM, no fast RAM. Runtime, firmware, source, phase, observer and capture identities are in results.json. This is configuration-specific native execution, not original-hardware conformance, every ROM/model or whole-game timing qualification. Neither language inherits the other's evidence.

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

A is held for an additional 90 fields before release in each action window. X is ignored, release and a new A act once more. These are named input windows, not an exhaustive keyboard arrival-time study. The original initial caller was also observed idle for 120 fields before the held-input sequence.

## Reproduce lawfully

Supply the matching firmware and runtime media; no licensed disks, ROMs, extracted runtime files or running snapshots are distributed. Use the released producer-locked emulator identified in the record. AMOS fixture creation uses released Build198x ADF 0.2.13. Source-only phase files retain the exact event sequence, including startup settling. They are a reproducible observed route, not a promise that the shortest possible UI sequence has been found.

The maintained runner is `scripts/replay-amiga-command-loops.py`. For AMOS, run `--prepare --builder /path/to/build198x-adf --output /fresh/run` first; this masters the Cases fixture directly from maintained source and generates only the two initial-state variants. For each replay supply `--language amos --emulator /path/to/emu198x-amiga --kickstart /path/to/kickstart.rom --output /same/run` and the relevant `--amos`, or `--blitz` and `--blitz-libs`, media arguments. Phase names are `amos-cases-cold.json`, `amos-cases-blank.json`, then one named `*-case.json`. Run cases sequentially or in independent sessions; they restore the empty-editor checkpoint. Keep snapshots private and disposable.

Phase execution checks tool errors, typed-character counts and completed native field runs. It prints “inspect the native captures”, not “passed”. Only observed program output justifies a behavioural pass. After a rerun, inspect the images and run `python scripts/check-amiga-command-loops.py` against the retained source/evidence record. CI rechecks retained evidence and failing controls; it does not boot licensed software.

## Failed paths retained as limits

Hot replacement of DF1 through generic load_media left the requester on the previous filesystem. Those first six transport-successful but requester-only cases were discarded. This matches tracked emu198x/emu198x#1877; its #1881 fix is still open at this review. Mounting Cases from cold boot removes that unqualified swap from the behavioural run. No duplicate bug or new hardware diagnosis is claimed.

The repaired caller is the same maintained program as working; the wrong caller changes only the placement of the counter initialisation. Default display/console setup, runtime memory use, save/reload, original-hardware behaviour, minimum hardware and other compilers remain separate qualifications.

## Publication pixels

Raw 1536 × 576 frames remain untouched for verification. The published 768 × 576 PNGs remove one column from every proven identical pair. `display_png` refuses any unequal pair and CI recomputes each export from the raw capture. No unique colour sample is discarded or invented. The existing site Figure component then handles the 4:3 capture and narrow layouts.
