# C64 and VIC-20 assembly deadlines

Issues: code198x/docs#176 and #183. Stack above samples #182; website above #972.

1. Audit existing Commodore command callers, BASIC daily-clock adapter and shared 6502 deadline helper. Keep stock firmware IRQ services and use GETIN delivered characters, with explicit repeat limits.
2. Add C64 `patterns/assembly/framework/turn-deadline/{demo.asm,settings.inc,clock.inc,input.inc,Makefile,README.md}`. Share the 6502 countdown and dispatch; expose a callable daily-clock normaliser. Add a VIC-20 wrapper with stock-memory placement and an independent qualification record.
3. Extend native observation via `scripts/verify-commodore-deadlines.py`: imported PRG with BASIC SYS, whole-code comparison, normal/custom/wrong/repaired cases, native helper/clock boundaries, wrong comparator and corrupted-record controls. Keep released tool and firmware hashes.
4. Add matching maintained-code website entries, native images, comparison links and focused browser assertions. Verify assembly, evidence controls, site checks/build and maintained listings.
5. Push paired PRs, link each above its existing native stack, retain source-first dependencies and issue-closing references. Clean task-owned worktrees and tools after verified remote preservation.
