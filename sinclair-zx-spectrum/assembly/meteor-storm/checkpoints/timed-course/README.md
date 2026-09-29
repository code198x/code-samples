# Measure time independently of progress

Each update now measures the frames since the last one: `frame_delta` is `frames` minus `last_frame`, an unsigned byte difference, and `elapsed` adds it to a 16-bit sum. `ticks` still counts course steps. Divide elapsed by 50 for whole seconds and multiply the remainder by two for hundredths. Counter arithmetic and display conversion are separate routines. The course ends well before the 16-bit counter wraps.

Predict, then check: if `last_frame` is 254 and `frames` is 0, the difference is 2, not -254. For 2092 frames the display is 41.84.

Space launches; O/P steer. One hit ends the run. R retries a result; Q returns to the title, in flight or at a result. The result retains the measured time.

Repeat: R at a result starts the same run again from a cleared state; Q then Space starts it from the title.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
