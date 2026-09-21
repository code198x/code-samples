# Move sideways more slowly

Add signed drift as the fifth byte of each object, and the fourth byte of each event. On every fourth course step, x+255 means x-1 modulo 256. At the left bound the stored drift becomes +1; at the right it becomes 255 (-1). Check the bounds before storing the new X.

O/P steer; Q restarts. R retries a result.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
