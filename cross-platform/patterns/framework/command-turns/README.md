# Firmware-command turn updates

These routines advance a byte-sized piece of game state for a delivered `G`
character. The routine itself neither reads the keyboard nor draws the display.
Use the complete Atom or CPC caller as a starting point, then replace the rule
inside `accept_command` with your own game operation.

## Call and state contract

Define `TURN` as four writable bytes owned exclusively by this routine and
`ACCEPT_KEY` as the character code to accept. Pass the initial counter in A and
call `init_turn` once. It sets the step to one and clears the result and saved
character. Put a different step in `TURN+1` after initialisation if required.

Pass each delivered character in A to `accept_command`. Test `TURN+2` immediately
afterwards: one means accepted, zero means rejected. A rejected character leaves
the counter unchanged. Every call replaces the acceptance result and saved input.

| Offset | Bytes | Meaning |
| --- | --- | --- |
| +0 | 1 | Counter, addition wraps modulo 256 |
| +1 | 1 | Step, preserved by the update |
| +2 | 1 | Accepted flag, 0 or 1 |
| +3 | 1 | Saved delivered character |

On 6502 clear decimal mode before use. A and status flags are clobbered; X/Y are
preserved. The two routines occupy 48 bytes with absolute state addressing
(including both RTS instructions). A direct JSR needs two return-address stack
bytes, in addition to any caller/firmware stack use. On Z80, initialisation
clobbers AF; acceptance clobbers AF/HL and preserves BC/DE. The routines occupy
45 bytes. A direct CALL needs two return-address stack bytes. Neither version
changes interrupt state or uses zero page/index registers/heap allocation.
Do not call either concurrently with another owner of the same context.

The caller waits through stock firmware. That service can deliver autorepeated
characters: one delivered character is not necessarily one physical press. For
held/pressed state use a non-blocking key scanner and edge detection instead.
This loop cannot service a game deadline while blocked on input.

## Complete native callers

- `acorn-atom/patterns/assembly/framework/command-loop`: expanded 32 KiB Atom,
  code at $2800, context at $2700; OSRDCH $FFE3 and OSWRCH $FFF4. The integer
  BASIC text starts at $2900, above the 139-byte executable. The code uses the
  space normally available to floating-point extensions: do not combine those
  extensions with this layout. This is not the base 2.5 KiB Atom configuration.
- `amstrad-cpc/patterns/assembly/framework/command-loop`: CPC464, context at
  $8FF0, code at $9000; KM WAIT CHAR $BB06 and TXT OUTPUT $BB5A. The loader
  lowers BASIC HIMEM using MEMORY before installing the executable. Normal
  firmware interrupts remain enabled.

Both loaders set two adjacent diagnostic guards, outside the four-byte routine
context. No firmware is distributed. `make` assembles original code and generates
a numbered BASIC listing. Type the complete generated listing, then RUN. `G`
advances the displayed hexadecimal count; `X` does not. The demo owns the text
screen and clears it after every delivered command.

`settings.inc` demonstrates the initial count, step and accepted character. A
step of two produces 00, 02, 04; an initial count of 254 produces FE, FF, 00.
If the application needs a larger or saturating counter, change the routine and
its contract; do not assume the byte demonstration supplies that policy.

## Wrong and fixed

`mistakes/reset-each-command.inc` is deliberately broken. Use it in place of
`dispatch.inc`, rebuild and start from cold firmware. It resets the state before
every dispatch: two accepted commands produce 00, 01, 01. Even a rejected command
can erase progress. Restore `dispatch.inc` to fix it. Keep initialisation outside
the recurring command path. The native verifier runs the repaired caller afresh.

## Reproduce

Use released Asm198x 0.0.71 and Emu198x 0.44.0. Each caller's
`qualification-toolchain.json` records archive, executable and producer identities.
Supply your own matching firmware; paths are arguments, not baked into samples.

```sh
python3 scripts/verify-loop-language-gaps.py --tools TOOL_RELEASE_DIRECTORY --firmware ROM_ROOT
python3 scripts/check-loop-language-records.py
python3 -m unittest discover -s scripts -p test_loop_language_records.py -v
```

The verifier enters real programs through keyboard input, compares installed bytes,
observes guest state, checks adjacent guards and captures rendered output. Cold
cases cover idle/rejection, custom step, nonzero start, wrap, the reset fault and
a separate repaired run. The retained checker checks identities and results; it
does not execute the emulator. These are configuration-specific observations,
not an original-hardware timing claim or a complete-emulator certification.

## Primary references

David Johnson-Davies, *Atomic Theory and Practice*, sections 13.14 (operating
system calls), 14.2 (LINK), 26 (memory allocation), and Appendix D (memory map).
Amstrad, *CPC464 Firmware*, entries KM WAIT CHAR (#BB06) and TXT OUTPUT (#BB5A).
