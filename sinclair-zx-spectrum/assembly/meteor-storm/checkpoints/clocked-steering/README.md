# Give the ship a measured rate

Replace the delay loop with the separately explored private interrupt and alternate-frame gate. O/P moves two pixels per update, or 50 pixels per second on the target PAL configuration. Extra drawing work must now fit the available interval.

O/P steer; R restarts. Both keys cancel.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
