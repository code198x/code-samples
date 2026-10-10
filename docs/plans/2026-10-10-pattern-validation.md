# Refresh audio evidence and execute Hardware Sprites

Approved scope: rerun the current NES audio sample, remove stale backlog
claims, then turn one illustrative pattern into an executed example.

1. In `nintendo-entertainment-system/patterns/assembly/audio/square-wave/`,
   extend `verification/verify.py` to check exported WAV pitch and duration
   against its header, alongside emulated time. Reject a deliberately
   mislabelled capture. Build the current emulator, run all seven ROMs,
   retain source/tool hashes and results, and update the README. Commit.
2. In the docs repository, remove completed C03a and triangle-repair items
   from `work.md`, preserving browser/listening acceptance and unrelated
   edits. Link exact evidence from a short reconciliation record. Commit.
3. Add `commodore-64/patterns/assembly/rendering/hardware-sprites/` with a
   complete shape, standalone BASIC-loadable caller and bounded sprite-0
   routine. Preserve other sprites' shared register bits; explicitly own
   the demo's screen, VIC bank and interrupt setup. Verify PAL and NTSC,
   low/high X, shape, colour and shared-bit preservation in Emu198x and
   VICE, compare Asm198x/ACME output, and reject a missing-X-bit mutation.
   Commit after checks pass.
4. In the website, consume maintained sprite sources through CodeFromFile,
   correct the DMA/CPU and pointer-bank explanations, and pin the new
   sprite and NES evidence links. Build and check the two rendered pages
   at desktop/mobile sizes. Commit and merge reviewed, passing changes
   within the user's existing merge authorisation.

Baseline: samples `be65631db11bac9127e85a76f448bef3806819a8`;
Emu198x `df2799e220a10de6a3bc0f14f04c6506363cb7d3`. The old NES observer
normalises pitch by its observed sample count, so it cannot reject the
documented header mismatch. Current APU code already contains fixes
`a1f23188` (sample rate) and `c63d1bc3` (triangle holding).
Hardware Sprites is labelled illustrative, supplies only five of its
21 shape rows, overwrites all X-high/enable bits, and calls display free.
No chip behaviour change, new dependency or schema is proposed.
