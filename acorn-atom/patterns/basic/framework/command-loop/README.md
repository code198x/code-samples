# An untimed command loop: Base Acorn Atom, 2.5 KiB RAM

Run the listing and the screen shows `TURN 0`. Type `1` and press Return: it shows `TURN 1`. Wait as long as you like; the game state stays put. Submit the command again for `TURN 2`.

## Use it

Enter [demo.bas](demo.bas) into the named machine's BASIC, then type `RUN`. It needs the machine's normal firmware, not a replacement ROM. Enter uppercase source and commands as shown. The verifier uses the emulator's real keyboard path.

Keep the initial `N=0` once at startup. Put your command handling where the listing tests the input, and your world update where it increments N. Keep INPUT in the loop: it is the point at which the player hands control back to the game. Renumber the listing when combining it with another BASIC program; there is no assembly include or hidden support file.

## Contract and ownership

`N` holds rule state; `A` holds the submitted command. `1` advances one turn; `0` leaves N unchanged. BASIC owns variable storage, keyboard scanning, screen output and its normal interrupt services. Other malformed input follows this BASIC's usual error handling; this small caller does not supply a full parser.

PRINT $12 clears the screen, the apostrophe prints a newline, and semicolons separate statements in this dialect. Qualification uses the Space correction in Emu198x PR #1863; a source file with ordinary spaces must survive keyboard entry.

The other BASIC counters use the dialect's normal numeric range. They are not unlimited integers. Screen redraw and input can take time, but neither is a turn deadline. To add timed turns later, choose a separate clock and timeout policy; do not assume INPUT will return periodically to check it.

## Reproduce the check

From the repository root:

```sh
python3 scripts/verify-command-loops.py --native /path/to/native/binaries --only acorn-atom
```

[The retained record](verification/results.json) identifies the firmware and executable, source hashes and exact configuration. The check submits accepted and ignored commands, waits without changing state, repeats from a nonzero initialiser, and rejects a caller that fabricates its first command. Byte-counter callers also check 254 → 255 → 0. This qualifies a small command caller, not a complete platform track or physical-hardware accuracy.

## Reusable update, customisation and a diagnosed mistake

The original `demo.bas` above remains the small probe. For an independently
callable rule update, enter `caller.bas` followed by `routines.bas`, then RUN.
These are two parts of one numbered BASIC program, not two programs to RUN in
succession. `customise.bas` replaces the caller; append the same routines.

Call GOSUB 1000 with N=current state, S=positive step and A=1
to accept an action. Other numeric values are rejected.
C=1 means accepted, C=0 rejected. N changes only for an accepted command.
The routine preserves the input and S, reads no keyboard and performs no drawing.
Reserve all four global variables, and lines 1000–1040. It is not re-entrant.
N and S use Atom integer arithmetic; keep their sum in range. No saturation or wrap policy is supplied.

The caller initialises once, draws, reads input, calls the update and repeats.
Atom uses semicolon statement separators and apostrophe newlines.
Renumber GOSUB targets if another part of your program owns those lines. This
shares BASIC globals, not private registers: the map-query routines also use C
and other variables, so rename consistently or save results before another call.

The step-two caller changes S from 1 to 2: successive accepted commands give
0 → 2 → 4. Each still makes one call; S is the amount added, not a second input.
The implementation, assets and scratch-variable count are unchanged. Redrawing
the screen still costs the same work; no runtime speed measurement is claimed.

**Deliberately broken:** `mistakes/reset-each-turn.bas` resets N before every
call. Its first accepted command looks fine, but the second still gives 1.
Even rejecting a later command resets N to zero. Use `caller.bas` instead: leave
the initialisation at startup and call GOSUB 1000 without resetting N.
The faulty caller is separate from the recommended implementation.

Reproduce the independent execution from the repository root:

```sh
python3 scripts/verify-basic-turn-routines.py --native /path/to/extracted/release/directories --only acorn-atom
python3 scripts/check-basic-turn-records.py
python3 -m unittest discover -s scripts -p test_basic_turn_records.py -v
```

Native directories follow the release layout, for example
`emu198x-acorn-atom-aarch64-apple-darwin/emu198x-acorn-atom`.
Use the identified firmware from your own installation; none is bundled.
`qualification-toolchain.json` pins the release archive and producer lock.
`verification/reusable/results.json` binds all source/observer inputs, firmware,
executable, full native captures and the following observations: idle and rejected
commands preserve working state; accepted commands set C, rejected commands clear
it; default steps give 0/1/2; step-two gives 0/2/4; a nonzero start gives 37/38/39;
the reset fault gives 0/1/1. 
The recorded checker verifies retained evidence; only the native verifier runs
the emulator. No timed-input, physical-hardware, sound-service or whole-emulator
claim follows from these checks.
