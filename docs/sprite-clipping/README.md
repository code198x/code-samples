# Aligned software-object clipping

Three distinct implementations share an interval problem: select the source samples that land inside the viewport before forming a screen address. They preserve signed off-screen positions and distinguish source stride from cropped width. Spectrum/BBC use byte columns; Amiga uses words. Existing lifecycle interfaces and evidence remain unchanged.

Each machine has a reusable axis routine, a bounded masked drawing wrapper and a complete original caller in `patterns/assembly/rendering/clipped-sprites/`. The native scene includes cropped edges/corners, interior images and invisible calls; bitmap/bitplane results are compared independently. Fixtures enumerate 220 axis cases per machine, including extreme signed positions, zero/full extents, multiple viewport limits and guards. Deliberately disabled clipping and lost source offsets must fail their respective output oracles.

`verification/results.json` binds the actual workload to sources, helpers, observer, tools, firmware identities and native captures. Firmware/snapshots are excluded. `scripts/check-sprite-clipping.py` rejects stale/incomplete retained evidence; `verify-spectrum-clipping.py` separately runs fresh CPU-level Spectrum checks in CI. This does not qualify original hardware, arbitrary-X shifts, a display deadline or an entire game's frame budget.

The BBC axis table uses debugger-injected RAM verified byte for byte before entry through BASIC CALL; its smaller visible caller is typed through the BASIC DATA loader. Negative drawing variants use the same CPU/output path with direct fixture loading. Spectrum callers load from tape through the real ROM, and Amiga scenes boot from ADF.
