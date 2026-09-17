# Tail Chase teaching checkpoints

Twelve standalone Sinclair BASIC checkpoints support ten lesson drafts. The last lesson saves and reloads the unit 9 endpoint. That endpoint is byte-identical to the accepted prototype: 24×16 arena, four to twelve body cells, eight foods, I/J/K/L steering, one queued perpendicular turn, R retry and Q exit.

`checkpoints.json` records each source and its exact additions, replacements and deletions. Each `snippets/` file contains only added or replaced numbered lines. These are editing instructions, not runnable programs; each `steps/` file is complete.

Units 6 and 7 each include a **diagnostic second step** that continues after one food, disables further food and permits a deliberate five-cell body collision. Their behaviour differs intentionally from the one-food challenge. Subsequent edits restore the ordinary ending.

## Recorded execution

`verification/evidence/summary.json` records twelve passed checkpoints and 76 named execution check groups, including the eleven final-round groups and three separate control groups. Every checkpoint was entered through ROM keyboard tokens and saved in a fresh emulator process, then loaded through the ROM for checks. Source hashes, saved-line bytes, tapes and results are retained per checkpoint. Tape checksums and a single header/data pair were checked. The final source matches the accepted native prototype exactly.

The independent model compares ordered positions, growth and rejected moves; grid stages compare all 384 occupancy entries. Repeated routes exercise body and clock-byte wraps. The full endpoint completes all eight foods, stops after success, retries and exits. The control check exercises the first queued turn, simultaneous keys and exit from a result. No game-state memory was injected.

The evidence is specific to Emu198x Spectrum 0.25.0 with a stock 48K PAL ROM. It is not original-hardware or novice-learner evidence. The accepted native prototype supplies human play feedback; the intermediate teaching programs were checked by scripted execution and selected captures.

## Reproduce

With an Emu198x Spectrum executable and its 48K ROM configured, run from this directory. Use a fresh output directory:

```sh
python3 verification/build.py --emulator /path/to/emu198x-spectrum --output /tmp/tail-teaching
python3 verification/check.py --emulator /path/to/emu198x-spectrum --output /tmp/tail-teaching
python3 verification/final.py --emulator /path/to/emu198x-spectrum --output /tmp/tail-teaching
python3 ../prototype/verification/controls.py --emulator /path/to/emu198x-spectrum --output /tmp/tail-teaching/eight-foods
python3 verification/audit.py --evidence /tmp/tail-teaching
```

The build enters each complete program through the ROM and records `SAVE "tail" LINE 10`. `--only NAME` selects a checkpoint; `--jobs` permits independent build processes. Each verifier starts a fresh process. The final verifier reuses the prototype's model after asserting identical source bytes. The entry harness is shared with the prototype and Meet BASIC.

`derive.py` is the authoring recipe for the checkpoint sources and edit manifest. It does not verify execution. After changing it, regenerate the files, inspect the changes and rebuild/recheck affected checkpoints. `audit.py` replays every source edit, checks literal branch targets and confirms that source and tape identities match execution evidence.

Load any retained `verification/evidence/NAME/tail.tap` through the ROM with `LOAD "tail"`. The early stages start directly; the final game begins at instructions. The game, character artwork and scripts use the repository's MIT licence.
