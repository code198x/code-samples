# Read a complete event schedule

Replace the three hand-written spawns with the accepted schedule's 100 meteor events, three bytes each: X, speed and the delay until the next event. `new_game` sets `wave_timer` to 20. `waves` counts it down once per update; at zero it reads event number `wave`, loads that event's delay, adds one to `wave` and calls `spawn`. Stars and drift are absent at this stage. The run is won only when `wave` equals `WAVES` and `active_count` is zero, after the hull check. Every replay uses the same prepared course.

Predict, then check: set `WAVES equ 3`. The third event, X=42 at speed 4, is read on update 36, but CLEAR SPACE waits until update 74, when that meteor passes y=174. Event exhaustion is not object exhaustion. Restore 100.

Space launches; O/P steer. One hit ends the run. R retries a result; Q returns to the title, in flight or at a result.

Repeat: R at a result starts the same run again from a cleared state; Q then Space starts it from the title.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
