# Decide contact from geometry

Watch meteor_y pass through 154..171. Contact additionally requires the absolute difference between ship_x and meteor_x to be less than 16. A horizontal difference of 16 is safe; 14 is a hit. Trace SUB, the carry-dependent NEG, CP 16 and the branch. No bitmap or colour read decides contact.

O/P steer; R retries. One hit freezes movement and displays HIT; a clean pass displays CLEAR SPACE.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
