# Measure time independently of progress

elapsed adds the difference between successive PAL frame bytes, using a 16-bit sum. ticks counts course steps instead. Divide elapsed by 50 for whole seconds and multiply the remainder by two for hundredths. For 2092 frames the display is 41.84. Counter arithmetic and display conversion are separate routines. The course ends well before the 16-bit counter wraps.

O/P steer; Q restarts. R retries a result. The result retains the measured time.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
