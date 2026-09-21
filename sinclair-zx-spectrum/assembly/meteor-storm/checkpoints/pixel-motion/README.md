# Move the ship between character columns

Keep the byte-column address and the sub-column offset separate. draw_sprite chooses a 64-byte shift block from x AND 7, then XORs four bytes for each of sixteen rows. Predict the address and table offset at x=14 and x=16: byte columns 1 and 2, shift offsets 384 and 0. This stage deliberately uses a workload-dependent delay.

O/P steer; both cancel. R restarts. Bounds are x=8 and x=224.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
