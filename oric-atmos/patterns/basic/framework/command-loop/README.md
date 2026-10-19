# An untimed command loop: Oric Atmos with the recorded ROM

Run the listing and the screen shows `TURN 0`. Type `1` and press Return: it shows `TURN 1`. Wait as long as you like; the game state stays put. Submit the command again for `TURN 2`.

## Use it

Enter [demo.bas](demo.bas) into the named machine's BASIC, then type `RUN`. It needs the machine's normal firmware, not a replacement ROM. Enter uppercase source and commands as shown. The verifier uses the emulator's real keyboard path.

Keep the initial `N=0` once at startup. Put your command handling where the listing tests the input, and your world update where it increments N. Keep INPUT in the loop: it is the point at which the player hands control back to the game. Renumber the listing when combining it with another BASIC program; there is no assembly include or hidden support file.

## Contract and ownership

`N` holds rule state; `A` holds the submitted command. `1` advances one turn; `0` leaves N unchanged. BASIC owns variable storage, keyboard scanning, screen output and its normal interrupt services. Other malformed input follows this BASIC's usual error handling; this small caller does not supply a full parser.

BASIC owns the keyboard, IRQ service and text screen. CLS redraws the current turn. Do not disable interrupts around INPUT.

The other BASIC counters use the dialect's normal numeric range. They are not unlimited integers. Screen redraw and input can take time, but neither is a turn deadline. To add timed turns later, choose a separate clock and timeout policy; do not assume INPUT will return periodically to check it.

## Reproduce the check

From the repository root:

```sh
python3 scripts/verify-command-loops.py --native /path/to/native/binaries --only oric-atmos
```

[The retained record](verification/results.json) identifies the firmware and executable, source hashes and exact configuration. The check submits accepted and ignored commands, waits without changing state, repeats from a nonzero initialiser, and rejects a caller that fabricates its first command. Byte-counter callers also check 254 → 255 → 0. This qualifies a small command caller, not a complete platform track or physical-hardware accuracy.
