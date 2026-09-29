# Turn a click into a tone

Bit 4 of port $FE moves the speaker; bits 0-2 set the border. Writing bit 4 high, waiting, then writing it low and waiting again makes one cycle of a square wave. The delay loop sets the period and the number of cycles sets the length. The finished game's impact made 12 cycles of about 11 kHz, 1.07 ms in all: a click. This impact makes 105 cycles of about 523 Hz, 200 ms in all. The run has ended at impact, so the game can afford to wait for it.

The code starts at 32768, above the contended RAM at $4000-$7FFF, so its instruction fetches run at full speed. Only each OUT to the ULA port may wait a few T-states while the screen is being drawn, a fraction of a percent here.

Timing at 3.5 MHz, where `djnz` costs 13 T-states per pass and 8 on the last:

| Part | T-states |
|---|---|
| High half: `ld b,n`, `djnz` loop, `ld a,d`, `out` | 13n+17 |
| Low half: the same, plus `dec e`, `jr nz`, `ld a,d`, `or 16` | 13n+40 |
| Period, n=IMPACT_HALF=255 | 26×255+57 = 6687, so 523.4 Hz |
| Length, IMPACT_CYCLES=105 | 105×6687 = 702,135, so 200.6 ms |

An Emu198x audio capture measured 522 Hz for 105 cycles, 199 ms; the old click measured about 11 kHz for under 1 ms.

The two halves differ by 23 T-states. That changes the tone's colour slightly, not its pitch. The old click: 313 T-states per period, 11.18 kHz, 12 cycles, 3756 T-states.

The border lives in the variable `border`. Every speaker write ORs it in instead of writing zero, so the tone leaves the border alone. It is black now; a later program colours each storm.

Predict, then check: halving IMPACT_HALF to 127 should raise the pitch by about an octave (26×127+57 = 3359 T-states, 1042 Hz) and halve the length unless IMPACT_CYCLES doubles. Assemble with `border: defb 2`: the border is red from launch and stays red through the impact, where the old routine would have turned it black.

Space launches; O/P steer; hold Space for 2X. One hit ends the run. R retries a result; Q returns to the title. Repeat the impact by leaving the ship still after launch: the first meteor to reach it ends the run.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
