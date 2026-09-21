# Separate display frames from updates

The only new gate is frames AND 1. The interrupt still arrives every PAL frame; main code counts alternate frames. After 600 frames the update word advances 300, even though the frame byte wrapped twice. Read the branch before coupling this clock to movement.

No keys. Reload or reset to repeat. Inspect frames and updates.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
