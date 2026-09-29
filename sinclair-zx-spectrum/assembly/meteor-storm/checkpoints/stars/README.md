# Print the score as decimal digits

The `score` byte gains a readable display. One score unit displays as ten points: `decimal3` writes three digit characters before a fixed trailing zero in `score_digits_text`, and `score_line` prints `score_text` at the top of the screen. `hud` redraws the score only when it has changed; `new_game` draws it once, and `result` redraws it so the result screen shows the final score. The game rules are unchanged from `star-pickups`.

Predict, then check: collect one star and the HUD reads SCORE 0010. The star vanishes and cannot score twice, because removal clears its kind before the next update.

Space launches; O/P steer. One hit ends the run. R retries a result; Q returns to the title, in flight or at a result. Stars award ten points.

Repeat: R at a result starts the same run again from a cleared state; Q then Space starts it from the title.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
