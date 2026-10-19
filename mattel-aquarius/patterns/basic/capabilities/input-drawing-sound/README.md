# BASIC input, text-cell drawing and a machine-code beep — Aquarius

Type demo.bas into stock BASIC and RUN. GO advances the displayed count, draws a three-row text-cell box and calls an original relocatable beep routine through USR. The base machine's one-bit sound/cassette pin is used; no Mini Expander AY chip is assumed.

The listing creates every scalar before DIM reserves an array. It installs beep.asm's bytes in that array's storage and points the BASIC USR vector at them. Creating new scalar variables later can move array storage, invalidating the stored address: reserve all variables first, or choose another explicit allocation strategy in a larger project. Keep DATA lines short enough for the stock editor; the listing splits them deliberately.

The 22-byte routine uses relative branches, preserves AF/BC and leaves BASIC's numeric argument/result workspace alone. It owns sound/cassette output port $FC bit 0, holds up the CPU for the beep and returns the pin low. Do not record a cassette while using it. BASIC owns the storage; do not reuse its array while the routine may run.

beep.asm is the maintained machine-code source. Its assembled bytes are the DATA payload in demo.bas; rebuild and compare them when changing the routine. Stock BASIC's USR vector is at 14340/14341. The array-allocation approach follows the documented working BASIC caller in [Aquarius Draw](https://aquarius.mattpilz.com/draw/); the beep implementation is original to this example.

The verifier exercises real keyboard entry and the stock BASIC path. It compares accepted-command PCM with an invalid-command baseline and requires the omitted USR call to fail the same sound guard. This is blocking input, text-cell drawing and a short blocking sound, not a complete real-time input/render/audio framework.
