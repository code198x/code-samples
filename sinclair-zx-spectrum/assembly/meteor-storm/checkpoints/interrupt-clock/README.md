# Count interrupts without a game

The handler increments frames while preserving AF. Main code counts one update per HALT and changes the border every 32 updates. Compare frames and the 16-bit updates across 256 interrupts: the byte wraps, the word continues. The private vector table has 257 identical $FD bytes, so every possible low vector byte points to $FDFD, a JP interrupt instruction.

No keys. Reload or reset to repeat. Inspect frames and updates.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
