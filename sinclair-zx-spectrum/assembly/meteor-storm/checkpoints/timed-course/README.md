# Show the time as seconds and hundredths

The measured `elapsed` gains a display. `seconds` divides it by 50 for whole seconds, leaving the remainder in L; `format_time` doubles the remainder into hundredths and uses `decimal3` to fill `time_digits`, with one writable padding byte, `time_pad`, before it. `hud` calls `format_time` on every update and prints `time_text` after a clear, then only the five digits. Counter arithmetic and display conversion are separate routines; the counter itself is unchanged from `elapsed-time`.

Predict, then check: for 2092 frames the display is 41.84. Change the fraction's `add a,a` to `nop`: `elapsed` still counts the same frames, but the hundredths shown are halved.

Space launches; O/P steer. One hit ends the run. R retries a result; Q returns to the title, in flight or at a result. The result retains the measured time.

Repeat: R at a result starts the same run again from a cleared state; Q then Space starts it from the title.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
