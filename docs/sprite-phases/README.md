# Prepared sprite phases and pixel positioning

Reusable wrappers select a phase from signed pixel X and feed the appropriate aligned clipped renderer. Spectrum/BBC use eight phases and three-byte prepared rows; Amiga uses sixteen phases and the existing two-word blitter renderer. Negative X uses floor division so the correct visible source pixels survive left clipping. Generated assets have distinct prefixes for use together in a game.

Native static phase galleries cover all phases in the interior and at top/bottom/left/right edges: forty draw calls on Spectrum/BBC and eighty on Amiga. Frame counters keep running after composition; no animation-cadence or whole-game frame budget is claimed. Guest bitmap/bitplane and entire source-bank bytes are checked against independent per-pixel expectations. Wrong phase, wrong source stride and logical rather than arithmetic division must each fail the bitmap oracle on all three machines.

The host asset oracle reconstructs transparent/opaque-off/opaque-ink pixels, checks padding and rejects corrupted payloads and malformed source data. The retained record binds source, generator, observer, tools, firmware identities and actual captures; it does not replace fresh execution. Firmware/snapshots stay local. The Spectrum CI workload separately executes the CPU/rendering path with a synthetic ROM and no external firmware. Native BBC uses its generated compact BASIC hexadecimal loader; negative fixtures inject and byte-check the same machine code before BASIC CALL.

Builds use the existing publishing toolchain interface by default, with standalone build198x-adf compatibility. The publishing download build is checked separately from assembly; a successfully assembled Hunk does not prove an ADF was mastered.
