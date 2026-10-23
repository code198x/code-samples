# Electron and CPC BASIC deadlines

Continue docs#138 with docs#165 (Electron BASIC) and #167 (CPC BASIC). Existing source base: samples main 987ba0c01c6bab88abf5cd5249f8bf4285a247b7. Leave pending assembly PR #180 and website #971 open; this batch is independent.

## Audit and design

Electron: reuse BBC BASIC's existing turn-deadline files and Makefile by delegation. Do not copy its helper or alter its existing bound records. Qualify Electron stock 32 KiB PAL, MODE 6, its own OS/BASIC and the shared low-16 centisecond TIME adapter separately.

CPC: port the same bounded subtraction policy to Locomotive BASIC, using ordinary real variables for 0..65535 values. Default integer variables cannot hold that range. Reduce the 300 Hz TIME value with division/subtraction, not a signed 16-bit bitwise mask. Use INKEY$ for nonblocking delivered characters and reuse the existing bounded command-loop update rule. Reserve a separate observer above MEMORY &9FFF; MODE 1 screen starts at &C000. No clock reset, custom IRQ, new dependency or architecture.

Both: untimed play remains valid. Expiry wins over a same-iteration character; one overdue event produces one turn and restarts. Active actions restart; untimed actions stay untimed. Toggle disables/discards remaining time; re-enable starts afresh. Shared labels/line ranges, global ownership, input repeat, numeric bounds, wrap and firmware side effects stay explicit.

## Tasks and verification

1. Add Electron delegation under `acorn-electron/patterns/basic/framework/turn-deadline/`; add CPC caller/helper/clock/monitor/custom/wrong/boundary source under `amstrad-cpc/patterns/basic/framework/turn-deadline/`. Reuse existing BBC source and CPC turn-rule expression; record exact dependencies.
2. Add a separate native observer/evidence checker in `scripts/*electron-cpc-basic-deadlines*`, importing existing transport and BBC memory-layout reader. Keep existing qualified source/observers unchanged. Cold-boot each released emulator, type all programs, run normal/custom/wrong/repaired callers plus a second arithmetic caller and faulty exact-boundary control. Bind tool/firmware/source/observer identities, guarded state and captures. Measure actual tokenised/heap bytes where the runtime layout is established; label other costs honestly.
3. Wire bounded CI evidence checking and meaningful corruption controls. Verify public Makefile paths, Ruff and native output, with source-checked primary manual references.
4. Prepare website entries via CodeFromFile, native captures/credits, contracts, customisation and error/repair explanation. Link Maths for Games where units/wrap explain the routine. Verify exact listings, links, source pins, desktop/phone layout, local site check/build, native PNG decoding and offline links. Create source-first PRs; website closes only #165 and #167.
5. Update issue progress, preserve task/source pins remotely, remove owned worktrees/tools/processes and keep native evidence in committed records and workspace outputs.

## Limits

Configuration-specific emulator execution is not original-hardware proof. Synthetic-clock arithmetic is separate from native clock accuracy. No minimum-RAM, whole-game budget or held-key edge guarantee for delivered character readers. Do not force an Atom BASIC clock into this batch: its polling/clock capabilities need their own investigation.
