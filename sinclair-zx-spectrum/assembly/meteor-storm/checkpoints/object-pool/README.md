# Walk the pool and reuse a slot

The three fixed records become a pool of twenty (`SLOTS equ 20`), with the same four-byte layout: X, Y, active, speed. `new_game` no longer chooses a record: it sets `spawn_x` and `spawn_speed` and calls `spawn` three times, for (80,2), (116,3) and (170,4). `spawn` searches for the first free record and fills it, or sets `pool_overflow` if none is free. `advance_meteors` replaces its three explicit calls with one loop that visits every record and moves only the active ones; `count_objects` counts them into `active_count`. The run is won when no record is active. IX points at the current record and B counts the slots left; callers save BC around drawing.

Predict, then check: each meteor retires on the first update that takes it to y>=174. Speed 4 leaves on update 38, speed 3 on update 50 and speed 2 on update 75, so `active_count` falls 3, 2, 1, 0 and CLEAR SPACE follows 75 updates (three seconds) after launch. Change `SLOTS equ 20` to `SLOTS equ 1`: the second and third spawns find no free record and set `pool_overflow`.

Space launches; O/P steer. One hit ends the run. R retries a result; Q returns to the title, in flight or at a result.

Repeat: R at a result starts the same run again from a cleared state; Q then Space starts it from the title.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
