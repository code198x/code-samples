# Carry a pixel into the next byte

The byte $81 represents 10000001. Shift the pair $81,$00 right once: the answer is $40,$80, not $40,$00. Inspect screen addresses $480C and $490C/$490D. The two scanlines show the original and shifted row.

No keys. Reload or reset to repeat.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
