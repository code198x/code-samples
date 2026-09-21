# Check both steps of a faster update

Space selects one or two race_step calls per update. Both steer and check every collision before deciding completion. A star awards one or two units according to the held key. This intentionally straightforward renderer draws each object twice while boosting; measure frame_delta in a dense field before changing it.

O/P steer; hold Space for 2X, release for 1X. Q restarts; R retries a result.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
