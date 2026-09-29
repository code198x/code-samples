# Move sideways more slowly

Add `ticks`, a 16-bit count of course steps, increased once per update: drift is the first thing that reads it. Add signed drift as the fifth byte of each object and the fourth byte of each event. When the low two bits of `ticks` are zero, one step in four, X changes by the drift byte: X+255 means X-1 modulo 256. At the left bound the stored drift becomes +1; at the right it becomes 255 (-1). Check the bounds before storing the new X.

Predict, then check: a meteor at X=8 with drift 255 adds up to 263, which wraps to 7. That is below 8, so its drift becomes +1 and X stays 8. Over 100 course steps a drifting meteor moves 25 pixels sideways. Change `and 3` to `and 7` and it moves half as far.

Space launches; O/P steer. One hit ends the run. R retries a result; Q returns to the title, in flight or at a result.

Repeat: R at a result starts the same run again from a cleared state; Q then Space starts it from the title.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
