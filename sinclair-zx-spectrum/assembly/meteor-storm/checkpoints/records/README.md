# Separate one run from a session

best_time and best_score sit outside state_start..state_end, the run block unit 11 introduced. Retry clears the run range only. $FFFF means no successful time yet. Only a successful finish updates the time record and awards 10 times max(0,100-whole seconds); both outcomes may update best score.

Predict, then check: with a 41.84-second finish the bonus is 590 points. Fail the next run: the best time stays, because a failed run cannot set one.

Space launches; O/P steer; hold Space for 2X, release for 1X. One hit ends the run. R retries a result; Q returns to the title, in flight or at a result. Records last until the program is reloaded or reset.

Repeat: R at a result starts the same run again from a cleared state; Q then Space starts it from the title.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
