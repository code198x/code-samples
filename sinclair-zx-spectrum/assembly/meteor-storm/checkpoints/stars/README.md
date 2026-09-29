# Make an object kind change the rules

The active byte becomes kind: 0 free, 1 meteor, 2 star. Restore all 120 accepted events, including twenty stars. Stars keep their X, award one score unit and retire on contact. One score unit displays as ten points: decimal3 writes three digits before a fixed trailing zero. Collecting never damages the ship. `hud` redraws the score only when it has changed; the result screen shows the final score.

Predict, then check: collect one star and the HUD reads SCORE 0010. The star vanishes and cannot score twice, because removal clears its kind before the next update.

Space launches; O/P steer. One hit ends the run. R retries a result; Q returns to the title, in flight or at a result. Stars award ten points.

Repeat: R at a result starts the same run again from a cleared state; Q then Space starts it from the title.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
