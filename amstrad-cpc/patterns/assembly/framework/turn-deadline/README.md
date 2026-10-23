# A turn can have a deadline on the CPC

Type and run the generated loader. Space advances the hexadecimal turn counter. At first you can wait as long as you like. Tap T to enable a deadline: a turn then ends without any input. Tap T again to stop timing. The internal turn counter is 16-bit; the small display shows only its low byte, so the visible value wraps after FF. A normal action restarts an enabled deadline while leaving untimed mode untimed.

```sh
make
```

Use Asm198x 0.0.71 or override ASM198X with its path. Type the complete `build/loader.bas`, then RUN. The loader reserves the memory used below. The reusable helpers are [documented separately](../../../../../cross-platform/patterns/framework/elapsed-deadline/README.md); include the matching `z80.inc` in a project with its own clock/input/display adapters.

## Native configuration and ownership

Choose **CPC464 PAL**, with stock firmware and interrupts enabled. The loader sets MEMORY &8FBF, reserving the caller state at $8FC0..$8FC9, the deadline context at $8FE0..$8FE9, guards at $8FEA/$8FEB and executable at $9000..$9145. Do not lower HIMEM after storing code or allow another module to allocate these bytes.

KL TIME PLEASE ($BD0D) returns DEHL in 1/300-second units. The adapter passes HL to the helper. The low word wraps after about 218.45 seconds; poll more often than that. Firmware time does not recover intervals during which interrupts were disabled. The firmware call itself enables interrupts, so this adapter is unsuitable for a caller that requires them disabled.

KM READ CHAR ($BB09) returns immediately with carry set when a character is available. This caller consumes delivered Space and T characters, including firmware repeat/typeahead: one delivered character is not one physical press. Holding T may toggle repeatedly; use deliberate short taps or substitute an independently verified state/edge reader for physical-button semantics. TXT OUTPUT owns text output in MODE 1. Reset leaves the demonstration; no prior screen restoration is supplied.

## Include and call

`settings.inc` names DEADLINE, STATE and DURATION. The helper state layout and register effects are in the shared README. Initialise once with the current clock. Poll each iteration, including while disabled. Consume the one-poll expiry flag immediately. The caller keeps its own turn counter, expiry count, redraw flag and input state in ten STATE bytes. Do not share those with another module.

If time and input coincide, expiry wins this iteration: one automatic turn is committed and the input is discarded. A later action starts a full new deadline only when timing is already enabled. Expiry starts the next turn from the observation time; it does not replay every hypothetical turn missed during an overrun.

## Make it your own

Change `DURATION` from 600 to 300 in `settings.inc`, rebuild and re-enter the loader. The shorter example is independently executed. It halves the chosen tick duration without another asset or additional state. The helper still uses the same code/RAM; only the constant changes. A duration of zero disables timing; 1..65535 are accepted. Different clock units, longer service gaps or a background interrupt clock need a new adapter/contract, not merely a larger constant.

## Common mistake: no input, no expiry

`mistakes/input-gated-expiry.inc` is deliberately wrong. Replacing `dispatch.inc` with it makes the caller discard the expiry unless an action arrives in that same iteration. The helper reaches remaining=0 and disables itself, but the displayed turn never advances. Polling the clock is not enough: the caller must act on the event even when no command was delivered. Restore `dispatch.inc` and repeat without input; a fresh repaired execution advances the turn. Keep this faulty include out of normal builds/downloads.

## Evidence and limits

`verification/results.json` binds the normal, shorter-duration, faulty and repaired stock-firmware executions to the exact source/tool/firmware identities and captures. Atom additionally exercises a near-wrap caller. Separate synthetic reset fixtures exercise twelve arithmetic cases and an independently rejected branch mutation; their results do not imply stock-firmware or display qualification.

The helper occupies 97 executable bytes and 10 context bytes. The complete caller is 326 bytes, plus ten caller-state bytes, two diagnostic guards, stack and firmware/loader/display requirements. Clock-rate observations cover 30 native frames. No original-hardware timing, missed-input guarantee or general game frame budget is claimed. See the shared README for reproduction commands and advanced alternatives.

## Primary references

Amstrad, *CPC464 Firmware* (1984), entries KM READ CHAR (#BB09), KL TIME PLEASE (#BD0D), and TXT OUTPUT (#BB5A); [firmware jumpblock manual](https://cpctech.cpcwiki.de/docs/manual/s968se14.pdf).
