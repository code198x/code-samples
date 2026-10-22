# Atari 800XL assembly: sample fire without repeating turns

Run `make` with released Asm198x 0.0.71 on PATH. Type the complete generated
`build/loader.bas` in stock Atari BASIC, then RUN. The loader selects GRAPHICS 0,
positions TURN 00 explicitly at column zero, writes the 177-byte program to
page six ($0600), then enters it using X=USR(1536). Press joystick-one fire:
TURN 00 becomes TURN 01; hold it without taking another turn; release and press
for TURN 02. The two digits are hexadecimal.

## Include and call

Define T as seven private consecutive bytes, then include the maintained
`cross-platform/patterns/framework/atari-turn-loops/turn.inc`. Decimal mode must
be clear. JSR init_turn with A=initial counter once. It clears previous/current
samples, field count and acceptance, and sets step=1. Change T+5 afterwards for
another step. Feed each active-high button sample in A to JSR sample_turn.
Call JSR service_tick once per accepted display-service interval if you want
the optional 16-bit diagnostic service counter. The rule routine does not wait,
read hardware or draw. The seven-byte layout is:

| Offset | Meaning |
| --- | --- |
| +0 | Counter, wraps modulo 256 |
| +1 | Previous active-high sample |
| +2/+3 | Serviced-field count, little endian, wraps modulo 65536 |
| +4 | Current sample |
| +5 | Step; preserved by updates |
| +6 | Accepted flag, 1 for a new press, 0 otherwise |

Initialisation and sample_turn clobber A/flags and preserve X/Y. service_tick
changes flags and preserves A/X/Y. A direct JSR needs two return-address stack
bytes; callers/OS interrupts need additional stack. The shared code is 77 bytes
with these absolute addresses and owns no private zero page. Do not reuse its
context from an interrupt while the foreground owns it.

## Native ownership and timing

The complete caller reserves T=$06E0–$06E6 and guards $06E7–$06E8. Its code ends
at $06B1, before the context, and the assembler rejects overlap. Page six is a
stock OS user area, not free in every language/runtime or DOS extension. This
layout requires stock Atari BASIC, no competing page-six code and no long INPUT
using its overflow buffer. Loading code elsewhere means revisiting the layout.
The loader itself is deliberately separate from the reusable include.

The USR entry consumes the argument-count byte using PLA. That is a BASIC entry
wrapper, not an instruction to put inside ordinary JSR routines. This complete
caller stays in its loop rather than returning to BASIC. Reset/reload to leave
it; it is not a cooperative handler with a return-value contract.

Normal OS VBI remains enabled. `wait_frame` waits for RTCLOK's low byte at $14
to change; its A/flags are clobbered, X/Y preserved. It neither disables IRQs nor
reads GTIA status. STRIG0 at $0284 is the OS-maintained active-low trigger shadow;
EOR/AND turns it into the active-high sample expected by the rule routine.
Screen writes follow SAVMSC ($58/$59). The caller owns the first display row;
the OS still owns display and keyboard services. Neither loop nor wait installs
an interrupt handler. A missing/replaced VBI can make the wait stall.

A changed low clock byte is a synchronisation opportunity, not a measurement of
all elapsed time. Work can miss fields, and waiting over 256 ticks can hide whole
wraps. Use a properly sampled multi-byte clock and expiry policy for deadlines.
The retained qualification is NTSC only; PAL has a different field rate.

## Change, break and repair

Replace settings.inc with customise.inc to add two per press, or wrap.inc to
start at 254. The context and routine sizes do not grow. nonzero.inc starts at
37 so lost initialisation cannot masquerade as zero-filled RAM.

The shared mistakes/held-as-press.inc deliberately drops the previous-sample
filter. Replacing edge-filter.inc with it makes held fire take repeated turns.
Restore the original filter and preserve previous state between calls.
The local mistakes/no-wait.inc deliberately returns immediately. Serviced fields
then count CPU iterations, not OS intervals. Restore frame.inc. Both faults and
independent repaired builds are executed by the verifier; a still capture alone
cannot establish the missing-wait timing failure.

```sh
python3 scripts/verify-xl-coleco-loops.py --only atari-assembly --tools TOOL_RELEASE_DIRECTORY --firmware ROM_ROOT
```

Eight fresh cases check real input, idle/held/released/second actions, custom
step, nonzero, wrap, both isolated faults and repairs. Installed bytes are
compared with assembled output; guards and source/tool/firmware identities are
retained in verification/results.json. These are configuration-specific native
observations, not original-hardware timing or a whole-game budget.

Sources: Atari *Atari BASIC Reference Manual*, USR stack convention; Ian
Chadwick, *Mapping the Atari*, RTCLOK 18–20, STRIG0 644, SAVMSC 88–89 and page
six 1536–1791. The stock OS API is reused rather than assuming the 5200's
cartridge/BIOS contract applies to an XL computer.
