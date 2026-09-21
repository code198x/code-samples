# Separate one run from a session

best_time and best_score sit outside state_start..state_end. Retry clears the run range only. $FFFF means no successful time yet. Only a successful finish updates the time record and awards 10 times max(0,100-whole seconds); both outcomes may update best score. With a 41.84-second finish the bonus is 590 points.

O/P steer; hold Space for 2X. Q restarts; R retries. Records last until the program is reloaded or reset.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
