# Check both steps of a faster update

Space selects one or two `race_step` passes per update. Both steer and check every collision before deciding completion. A star awards one or two units according to the held key. This intentionally straightforward renderer draws each object twice while boosting; measure `frame_delta` in a dense field before changing it.

Predict, then check: hold Space for a whole run. The course takes half the updates, but watch `frame_delta` in the densest part: it sometimes reads 4, an update that missed its two-frame interval.

Space launches; O/P steer; hold Space for 2X, release for 1X. One hit ends the run. R retries a result; Q returns to the title, in flight or at a result.

Repeat: R at a result starts the same run again from a cleared state; Q then Space starts it from the title.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
