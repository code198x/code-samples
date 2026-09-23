# An optional Crates map converter

After unit 08, we can write a room as eight plain-text rows and let a small
Python program add the BASIC line numbers and DATA syntax. The existing BASIC
loader still checks the room when we run it. This tool runs on our development
computer; it adds no Python dependency to the Spectrum game.

We need Python 3.10 or later, with no extra packages. Open a terminal in this
folder and run:

```sh
python3 map_to_data.py room.txt -o /tmp/crates-room.bas
```

On Windows, use a suitable output path, such as `crates-room.bas` in this folder.
A successful command prints `Wrote ...`; an error prints `Error: ...` and exits
with a non-zero status. The destination folder must already exist.

## Inspect what we made

[room.txt](room.txt) is the supplied room from unit 08, without line numbers or
quotes. Its first two rows become:

```basic
8000 DATA "########"
8010 DATA "#------#"
```

The output contains only eight lines, 8000–8070. It is not a whole game or a
Spectrum tape image. In a copy of the unit-08 program, replace those eight DATA
lines with the output, then RUN and press S. Check the room, make a move and
restart. Keep the original program as our recovery copy. Do not replace the
whole BASIC program with the generated file.

This version deliberately handles one room at the unit-08 line numbers. Later
multi-room checkpoints use other DATA blocks; we have not built a general
multi-room exporter or automatic program editor.

## What the converter checks

We use the same symbols and structural rules as the BASIC loader:

- Exactly eight rows, each with eight symbols. An optional final newline and
  Windows CRLF line endings are accepted. Extra blank rows are errors.
- `-` floor, `#` wall, `.` target, `C` crate, `*` crate on target, `P` player,
  `+` player on target. Spaces, lowercase letters and unknown symbols are errors.
- Exactly one player, at least one crate, and equal crate and target counts.
  A `*` counts as both crate and target; a `+` counts as both player and target.

The source file is UTF-8 text, not a document from a word processor. We do not
trim spaces or turn unfamiliar characters into floor. Row and column numbers
start at 1. For example, `#--X---#` on row 2 reports row 2, column 4; a seven-cell
row reports its actual length. Count mismatches report totals for the room.

These checks do not prove that a puzzle is solvable. An already-delivered room
is structurally valid, just as it is in the game. Enclosed borders are not an
additional rule: the existing game checks movement bounds itself.

## Follow the small tool

Read [map_to_data.py](map_to_data.py) in three pieces:

1. `convert` checks dimensions and symbols, counts objects and only then builds
   all eight DATA lines. It does not write a file while checking individual rows.
2. `write_output` writes the finished text to a temporary file beside the
   destination and replaces the destination after the write completes.
3. `main` reads the input, reports failures and refuses to use the same file for
   input and output.

If validation fails, no new output is created and an existing output is left
unchanged. **That old file still describes the previous successful map.** Fix
the error and rerun successfully before using it. A file's existence alone does
not establish that our latest edit was converted. Never redirect output over the
input file; use the documented `-o` option.

## Author checks

```sh
python3 -m unittest discover -s . -p 'test_*.py'
```

Four test groups pass: exact comparison with unit-08 DATA (including LF/CRLF and
optional final newline), malformed dimensions/symbols/counts, combined symbols,
and command-line file safety. Failed conversion preserves an existing output,
creates no fresh output and cannot overwrite its own input. No third-party test
framework is required.

## Follow an edit into the game

The optional exercise in [Crates unit 08](https://code198x.com/systems/sinclair-zx-spectrum/basic/crates/unit-08-check-a-room-before-playing/#optional-which-room-did-we-build)
compares the supplied DATA, leaves old output behind after an X-symbol error,
and moves P from column 3 to column 4 after a successful rebuild. It asks us to
predict the result before replacing the DATA in BASIC, then restore the original
map and check movement and restart. Use copies of the source map and game.

The converter does not edit the program already running in the Spectrum.
Authoring, conversion and consuming the generated DATA are three explicit steps.
No round-trip format is promised: output is for BASIC to consume, not an editable
source we need to recover automatically.

### Reproduce the consumer check

From this folder, with a locally built native Spectrum emulator:

```sh
python3 verify_consumer.py --emulator /path/to/emu198x-spectrum --output /tmp/crates-consumer
```

This uses the existing teaching verifier to enter unit 08 through the ROM keyboard
editor, replaces only map DATA and reads back game state and display memory.
It checks the known room, stale output after a rejected X, a regenerated player
position and restoration. Each case includes a left move and restart. It also
checks that tokenised program lines outside 8000–8070 remain unchanged. Source,
converter and emulator hashes accompany the results. This is emulator evidence;
it does not establish original-hardware accuracy, puzzle solvability or learner
understanding.

[Recorded results](consumer-results.json): all four consumer cases passed on
22 September 2026 in native Emu198x Spectrum 0.24.0, 48K PAL. The four host test
groups also pass. These checks do not include original hardware or a learner trial.
