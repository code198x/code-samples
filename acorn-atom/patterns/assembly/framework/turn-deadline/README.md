# A turn can have a deadline on the Atom

Type and run the generated loader. Space advances the hexadecimal turn counter. At first you can wait as long as you like. Tap T to enable a deadline: a turn then ends without any input. Tap T again to stop timing. The internal turn counter is 16-bit; the small display shows only its low byte, so the visible value wraps after FF. A normal action restarts an enabled deadline while leaving untimed mode untimed.

```sh
make
```

Use Asm198x 0.0.71 or override ASM198X with its path. Type the complete `build/loader.bas`, then RUN. The loader reserves the memory used below. The reusable helpers are [documented separately](../../../../../cross-platform/patterns/framework/elapsed-deadline/README.md); include the matching `6502.inc` in a project with its own clock/input/display adapters.

## Native configuration and ownership

Choose the expanded **32 KiB Atom**. The loader and its BASIC workspace must fit below the reserved $5F00 context; the executable occupies $6000..$61DE. This does not fit the stock 2.5 KiB machine. The BASIC text starts in expanded RAM below the reserved code; do not combine this layout with other owners of those regions. The public loader uses ordinary byte assignments followed by LINK #6000. It distributes no firmware.

The caller samples PC7 at $B002 and counts observed high-to-low transitions. In the qualified PAL emulator this yields 50 ticks per second; the original manual's nominal 60 Hz description is not a claim that this PAL configuration runs at 60 Hz. A 100-tick duration is approximately two seconds while sampling continues, but lengthy rendering, sound or other work can miss flybacks and lengthen it. This is not an elapsed clock that recovers missed fields.

The key adapter reads Space and T through PPI keyboard selection. It preserves and restores $B000's graphics-mode nibble and selector. It owns those scans during execution; another keyboard or display-mode writer must coordinate with it. Only fresh press edges count. A press between samples can be missed. The demo uses stock character output and owns the screen until Break/reset; it does not restore previous screen contents.

## Include and call

`settings.inc` names DEADLINE, STATE and DURATION. The helper state layout and register effects are in the shared README. Initialise once with the current clock. Poll each iteration, including while disabled. Consume the one-poll expiry flag immediately. The caller keeps its own turn counter, expiry count, redraw flag and input state in ten STATE bytes. Do not share those with another module.

If time and input coincide, expiry wins this iteration: one automatic turn is committed and the input is discarded. A later action starts a full new deadline only when timing is already enabled. Expiry starts the next turn from the observation time; it does not replay every hypothetical turn missed during an overrun.

## Make it your own

Change `DURATION` from 100 to 50 in `settings.inc`, rebuild and re-enter the loader. The shorter example is independently executed. It halves the chosen tick duration without another asset or additional state. The helper still uses the same code/RAM; only the constant changes. A duration of zero disables timing; 1..65535 are accepted. Different clock units, longer service gaps or a background interrupt clock need a new adapter/contract, not merely a larger constant.

## Common mistake: no input, no expiry

`mistakes/input-gated-expiry.inc` is deliberately wrong. Replacing `dispatch.inc` with it makes the caller discard the expiry unless an action arrives in that same iteration. The helper reaches remaining=0 and disables itself, but the displayed turn never advances. Polling the clock is not enough: the caller must act on the event even when no command was delivered. Restore `dispatch.inc` and repeat without input; a fresh repaired execution advances the turn. Keep this faulty include out of normal builds/downloads.

## Evidence and limits

`verification/results.json` binds the normal, shorter-duration, faulty and repaired stock-firmware executions to the exact source/tool/firmware identities and captures. Atom additionally exercises a near-wrap caller. Separate synthetic reset fixtures exercise twelve arithmetic cases and an independently rejected branch mutation; their results do not imply stock-firmware or display qualification.

The helper occupies 140 executable bytes and 12 context bytes. The complete caller is 479 bytes, plus ten caller-state bytes, two diagnostic guards, stack and firmware/loader/display requirements. Clock-rate observations cover 30 native frames. No original-hardware timing, missed-input guarantee or general game frame budget is claimed. See the shared README for reproduction commands and advanced alternatives.

## Primary references

David Johnson-Davies, *Atomic Theory and Practice* (1980), §25.5 (PPI port allocation), §25.6 (memory map), §13.14 (operating-system calls) and §14.2 (LINK). The PAL field observation is configuration-specific execution evidence.
