# Reusable deadline batch

## Design
Preserve existing untimed loops. Add independently callable elapsed-clock/deadline state, with clear action/expiry ordering and wrap limits. Extend native firmware-facing callers, using nonblocking input so a deadline can expire without a command. Reuse current source and transport; no new dependencies, generic engine or matrix work.

## Sequence
1. Atom assembly (#162) and CPC assembly (#166): inspect primary clock/input references and existing loaders. Build bounded callers, customise duration, execute revealing wrong/fixed cases and wrap/idle/action/expiry checks. Files: new per-machine `patterns/assembly/framework/turn-deadline/`, shared CPU deadline includes only where genuinely common, dedicated verification/checker/tests and samples plan.
2. C64 BASIC (#177) and BBC BASIC (#174): reuse language callers, native firmware clocks and nonblocking input. Independent named-configuration evidence and costs.
3. Ace FORTH (#189), AMOS (#178), Blitz (#180): inspect language clock and input contracts, reuse available ROM/runtime transports, qualify separately. Do not substitute assembly or host execution for language evidence.
4. Author corresponding `src/content/patterns/.../framework/turn-deadline.mdx` entries and useful comparison links. Use maintained CodeFromFile listings pinned to the source commit; inspect desktop/phone rendering and source agreement, run relevant repository gates.
5. Commit/push coherent slices, create source and website PRs with dependency and evidence notes, attach each PR, update issue progress without closing unfinished families. No merge/deploy requested. Clean owned worktrees/builds/processes after verifying remote refs retain work and evidence.

## Verification
Fresh native execution of public callers and diagnostic variants; independently computed state/clock expectations, guards and useful captures. Retained record checkers must reject corrupt/missing evidence. Name source/tools/firmware/runtime and distinguish direct fixtures from stock loading. Report exact unpassed checks.

## Review slices

The first paired source/website PRs contain only Atom assembly (#162) and CPC assembly (#166). The remaining five recommended language routes are subsequent independent slices, not claimed delivered by this pair. No matrix edits or merge/deployment are included.
