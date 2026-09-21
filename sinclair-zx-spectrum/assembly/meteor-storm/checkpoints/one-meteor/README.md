# Keep two positions independent

The meteor starts at (116,24), advances three pixels per update and retires at y>=174. It therefore needs 50 updates, or two seconds at 25 Hz. Move the ship and observe that meteor speed and X do not follow it. XOR the old image before changing position.

O/P steer; R restarts. Contact has no effect yet. CLEAR SPACE appears when the meteor leaves.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
