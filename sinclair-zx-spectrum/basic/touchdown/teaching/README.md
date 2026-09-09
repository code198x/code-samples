# Touchdown teaching checkpoints

Sixteen runnable game checkpoints support the agreed eleven-lesson sequence, with a separate simultaneous-input diagnostic. `roster.json` records the exact added, replaced and deleted lines for each step; `snippets/` contains just the added and replaced lines. Keep readable keyword spaces in all maintained sources.

The progression is scaled position → gravity → unlimited thrust → retry → fuel → a wide flat pad with single-key controls → combined controls → a flat height array → staged terrain → custom characters → the final challenge and result sounds. Lesson 4 introduces AND in its menu filter; lesson 5 reinforces it in the fuel decision. The final program is identical to the reviewed prototype. Practice starts at column 18 with pad columns 20–27; the final site starts at column 6 with pad columns 23–26.

## Reproduce

From this directory, with Python 3 and Emu198x Spectrum 0.22.1 configured with a lawfully supplied 48K ROM:

```sh
python3 verification/checkpoints.py --emulator /path/to/emu198x-spectrum --output /tmp/touchdown-teaching
python3 verification/diagnostic.py --emulator /path/to/emu198x-spectrum --output /tmp/touchdown-input
python3 verification/cases.py --emulator /path/to/emu198x-spectrum --tape /tmp/touchdown-teaching/touchdown.tap --output /tmp/touchdown-cases
python3 verification/lessons.py --website /path/to/website
```

The first three scripts enter source through the ROM, simulate keyboard events and inspect state without injecting flight state. `cases.py` explicitly edits starting lines through the ROM to isolate boundary cases. The checkpoint run saves a final tape through the ROM; the cases run loads it in a fresh emulator. Generated tapes are local outputs, not maintained sources.

## Recorded evidence

All sixteen checkpoints passed line admission, uncontrolled contact and exit. Every thrust-capable checkpoint also completed a safe approach, including the one-key-at-a-time practice game. All eight diagnostic input combinations passed. The additional cases cover practice-pad edges and adjacent misses, empty fuel, a safe empty-tank coast, the raised-array experiment, ascending side contact and held-Q release.

`verification/*-results.json` records those runs; checkpoint and diagnostic evidence includes source hashes. `verification/equivalence.json` records byte-identical final BASIC source and identical 3,071-byte stored program regions in the new teaching tape and the reviewed prototype tape. Tape files differ in their saved runtime data. The prototype's retained full boundary/retry checks therefore apply to the same final program; they are not presented as newly repeated teaching runs.

`captures/` contains fresh teaching-run captures: the single-key practice landing, final landing and combined-input diagnostic. The website overview uses the prototype's existing flight capture of the identical final program.

All execution is on the configured 48K PAL emulator. Frame counts include this harness's observation cadence; they are not a fixed frame-rate claim. Automated success does not establish beginner difficulty or enjoyment. The user played the native final prototype and reported that it works well and is quite hard. The eleven lessons and their easier stages are approved for publication; no new subjective audio or original-hardware claim is made.
