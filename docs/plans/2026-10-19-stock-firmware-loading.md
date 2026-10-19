# Qualify stock-firmware loading on MTX and Einstein

The ROM-socket callers test the hardware, but do not qualify the usual route from a developer's program to a running game. Keep those scopes separate.

1. Reproduce loading through MTX BASIC on the current native emulator. Use the documented POKE / USR interface and verify a nonzero return value, then run the original input caller from RAM. Files: `memotech-mtx/patterns/assembly/framework/input-loop/{demo.asm,Makefile,README.md}`, and `scripts/verify-stock-firmware-loaders.py`.
2. Reproduce the Einstein stock MOS disk boot route with an original, synthetic boot sector. Inspect the actual ROM handover before choosing load addresses. Use the existing runtime disk slot; do not replace MOS or pretend the sector-transfer test proves an application ran. Files: `tatung-einstein/patterns/assembly/framework/input-loop/{demo.asm,Makefile,README.md}`, an existing-convention disk builder, and the same verifier.
3. Track confirmed defects against existing issues where possible. MTX #261 is reopened; #263 already covers cassette transport. Einstein's earlier disk-slot issue #273 was fixed; do not reopen it without a reproducer.
4. Verify visible feedback, independently observed state changes, idle stability, held-key behaviour and a negative control. Record source, firmware and executable hashes and exact startup routes. Add these callers to the fleet inventory only after their runs pass.
5. For emulator fixes, write a failing regression before changing implementation, use a separate branch/PR, run affected tests and Clippy, push the commits and link them to the sample evidence. Do not change chip timing to work around a loader problem.
