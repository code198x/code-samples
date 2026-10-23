# MOS turn deadlines: BBC Micro and Electron assembly

## Audit and design

Continue docs#138 with docs#164 and docs#173. Both maintained game-loop callers already use MOS with firmware IRQs enabled and a typed MODE 6 loader. Reuse their startup approach, the shared elapsed-deadline/6502.inc arithmetic and Atom dispatch, rather than add a second deadline algorithm. BASIC remains an independent route; the existing C64/BBC BASIC PRs are being completed separately.

Use OSWORD 1 into a five-byte owned buffer; pass its low 16 centiseconds to the helper. Read keys through OSBYTE 129, with physical Space/T rising edges. Expiry wins over simultaneous input, one overdue turn, restart on active action, fresh enable and discard remaining on disable. Preserve MOS vectors/timers; no direct ULA/VIA code, IRQ replacement or system-clock reset.

## Steps and exact ownership

1. Add `bbc-micro/patterns/assembly/framework/turn-deadline/{demo.asm,settings.inc,clock.inc,input.inc,dispatch.inc,loader.py,Makefile,README.md}` and a revealing wrong dispatch. Add Electron delegation and README under its same path. Reuse shared 6502 helper unchanged.
2. Add native qualification and retained-evidence checks in `scripts/*mos-deadlines*`. Cold boot both released emulators, type loader, compare all installed bytes, observe guarded state and visible output. Exercise untimed idle/action, enable, clock/countdown agreement, no-input expiry, restart, disable, custom duration and wrong/repaired paths. A second ROM-free arithmetic caller covers wrap/exact equality and rejects a single faulty branch. Retain hashes, captures, measured binary/storage costs. No guest-state injection for public runs.
3. Wire bounded CI evidence check and corruption controls into `.github/workflows/pattern-evidence.yml`. Run meaningful failing controls and Ruff.
4. Add machine-specific website entries via CodeFromFile, capture/credit, error/repair/customisation, memory/register contracts and Maths for Games links. Add comparison links. Source pins must survive rebase merge. Verify listings/images, internal links, mobile overflow, focused browser tests, site/type/build gates; inspect visual captures.
5. Push samples and website PRs. Website closes only docs#164 and #173. Update parent progress and clean owned worktrees/tools/processes, retaining all commits remotely and evidence here.

## Limits

Named stock 32 KiB PAL configurations, MODE 6, supplied OS/BASIC firmware only. Same MOS ABI is not evidence of equal hardware timing. Neither helper nor native tests claim all MOS calls, minimum RAM, original hardware, NTSC or a whole-game budget. A low-16 clock must be sampled in less than 65536 centiseconds; reset is not wrap. Keep readable shared code and explicit machine differences.
