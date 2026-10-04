# Make each storm harder

The voyage's five storms come from the same rules: speeds of 2 to 5 pixels per update, 6 to 10 updates between spawns, a sideways drift every fourth update and the same colours. Reaching the fifth storm should feel like getting somewhere. This program gives each storm its own rules, kept as data: five bytes per storm in a table, `storm_rules`.

| Storm | Extra speed | Gap cut | Drift mask | Colours |
|---|---|---|---|---|
| 1 | 0 | 0 | 3, every fourth update | `row_colours`, as before |
| 2 | 1 | 1 | 3, every fourth update | `storm_2_colours` |
| 3 | 1 | 2 | 1, every second update | `storm_3_colours` |
| 4 | 2 | 2 | 1, every second update | `storm_4_colours` |
| 5 | 2 | 3 | 0, every update | `storm_5_colours` |

Each record is three bytes and a `defw`: the extra speed added to every spawn, the number of updates taken off every gap between spawns, the drift mask and the address of a 24-byte colour table. `start_storm` finds storm `storm`'s record at `storm_rules` plus five times `storm`, with five `add hl,de` as `waves` finds an event, and copies the bytes into `storm_speed`, `storm_cut`, `drift_mask` and `band_colours`.

The courses do not change: the event tables are the same five. The rules change how they are read. `waves` adds `storm_speed` to each event's speed with `add a,(hl)`, and subtracts `storm_cut` from each delay. The smallest delay is 6 and the largest cut 3, so a gap never falls below 3 updates.

Drift used `ld a,(ticks)` and `and 3`: the low two bits of the course step are zero on every fourth step. `drift_mask` replaces the 3. A mask of 1 tests only bit 0, true on every second step; a mask of 0 makes `and` give zero every time, so meteors drift on every update.

The colours were one table, `row_colours`, written by `clear`. Its attribute loop is now also a routine of its own, `paint_bands`, and reads the table whose address is in `band_colours`. The title sets `band_colours` to `row_colours`; `start_storm` sets it to the storm's table; the interlude calls `paint_bands` after starting the next storm, so the colours change between storms with no clash in flight. `new_game` now calls `start_storm` before `clear`, so a retry paints the first storm's colours even after a run that ended in the fourth. Each later table keeps the cyan HUD, white score and white ship rows; the storm itself turns hotter: storm 5 is red from top to bottom.

Faster, closer meteors also make storms shorter: on the measured keyboard route the five storms take 20.92, 18.28, 15.56, 16.08 and 12.08 seconds, so later bonuses grow as well as their multipliers.

Every storm must stay survivable by design, not by luck. The host route model reads the rules from the program's memory and finds a keyboard route through each storm under its own rules; the checks fly all five and confirm that every falling object's speed is its event's speed plus its storm's.

Predict, then check: make storm 5's record `defb 2,3,3`. What changes in the fifth storm, and what stays the same? Then try a gap cut of 6 for storm 5 and predict what `sub c` does to an event whose delay is 6... `wave_timer` becomes 0, and `waves` decrements it before testing, so the next spawn waits 256 updates.

Space launches; O/P steer; hold Space for 2X. One hit ends the voyage. At the result R retries from storm 1 and Q returns to the title.

Repeat: cross the first storm. The second starts in green, yellow, magenta and red, with meteors a little faster and a little closer together; by the fifth, everything is red and drifting every update.

Sources: the Zilog Z80 CPU User Manual for `ADD A,(HL)`, `SUB r` and `AND r`.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
