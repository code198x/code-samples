# Make an object kind change the rules

The active byte becomes kind: 0 free, 1 meteor, 2 star. Restore all 120 accepted events, including twenty stars; each event gains a fifth byte, its kind, which `spawn` stores through `spawn_kind`. Stars skip drift and keep their X. After the shared contact test, a star adds one unit to `score` and takes the removal path; any other kind reaches `meteor_contact` and clears `hull`. `draw_meteor` selects `star_sprites` for kind 2, and both pictures meet at `draw_object`. Collecting never damages the ship. The score is not printed yet: read `score` in the inspector or debugger. One unit means ten points.

Predict, then check: collect one star and `score` reads 1. The star vanishes and cannot score twice, because removal clears its kind before the next update. Change one star event's kind from 2 to 1 in `assets.inc`: it uses meteor artwork, drifts and destroys the ship on contact.

Space launches; O/P steer. One hit ends the run. R retries a result; Q returns to the title, in flight or at a result.

Repeat: R at a result starts the same run again from a cleared state, with `score` back at 0; Q then Space starts it from the title.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
