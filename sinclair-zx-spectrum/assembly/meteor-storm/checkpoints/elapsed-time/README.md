# Measure time independently of progress

Each update now measures the frames since the last one: `frame_delta` is `frames` minus `last_frame`, an unsigned byte difference, and `elapsed` adds it to a 16-bit sum. `new_game` records the current `frames` in `last_frame` as the run's baseline. `ticks` still counts course steps. The time is not printed yet: read `elapsed` in the inspector or debugger. The course ends well before the 16-bit counter wraps.

Predict, then check: if `last_frame` is 254 and `frames` is 0, the difference is 2, not -254. Most updates record `frame_delta` 2; the first of a run may record 1. At a result `elapsed` stops, while the interrupt's `frames` keeps counting.

Space launches; O/P steer. One hit ends the run. R retries a result; Q returns to the title, in flight or at a result. The result keeps the measured `elapsed`.

Repeat: R at a result starts the same run again from a cleared state and a new baseline; Q then Space starts it from the title.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
