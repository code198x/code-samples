# Fill the early Pattern Library columns

Preserve existing review branches #165/#937; new work is stacked on them and stays unmerged for review.

1. Inventory the remaining Loops routes and the 30-machine capability inputs/sounds. Distinguish stock language availability, accepted commands, held samples and edges; do not mark unsupported routes complete.
2. Loops batch: finish Oric, ZX80/ZX81, Sord M5, Spectravideo and Einstein using existing firmware/cart paths. Add usable modules/callers and explanations, retaining screen servicing differences. Use current released tools; verify normal, custom, nonzero, wrap and fault/repair cases where applicable.
3. Input batch: extract reusable machine/language routines from verified callers; preserve exact instruction or BASIC statement sequences where possible. Document state, outputs, resource ownership, held-versus-edge semantics and adaptations. Verify source/binary equivalence and actual execution, including rejected controls.
4. Sound batch: expose reusable trigger/stop/service contracts for the same native routes, with genuine channel ownership and timing limits. Stock ZX80/ZX81 have no speaker; record that limitation rather than inventing a sound routine. Compare recorded PCM with muted controls.
5. Commit each coherent source batch, run independent evidence checkers and falsification controls, push. Add matching website entries using CodeFromFile, native captures/audio and precise primary citations. Verify full check/build and representative desktop/mobile routes. Open source-first companion PRs.
6. Update docs#117 and the language-separated matrix with reviewed versus published distinctions; regenerate its static table, retain the eight-operation startup repair, check interactions/themes/narrow width. Preserve evidence/remote commits and remove task worktrees, tools and processes.

Exact files will be listed in each committed source batch manifest; no changes to legacy qualification source/records merely to move matrix states.

## Completed implementation

The exact 26 machine/language folders, module names and contracts are in `docs/column-expansion.json`: twelve BASIC routes, one FORTH route and thirteen assembly routes. The new website tranche supplies six remaining machine-level Loops entries, 26 Input entries and 24 Sound entries; existing core-system entries supply the other four machine paths. This does not complete every language row. Stock ZX80/ZX81 sound remains absent.

The native observers are `scripts/verify-column-{basic,basic-errors,hardware,edges,forth,zx,mos}.py`; `finalise-column-evidence.py` retains their actual artifacts. `check-column-evidence.py`, its eighteen falsification tests and the additive CI job check source bindings, actual memory decoding, image change/restoration, working/muted PCM, BASIC line collisions and explicit hardware absence. The original thirty-machine capability inventory is unchanged.

Common-error runs include stale accepted commands, missing press-edge filtering, double addition, a fabricated FORTH key and omitted sound. The Aquarius DATA/subroutine line collision is preserved with its native OD Error capture and a verified 4000-range repair. The DMG sampler uses the manual's six settling reads. The Coleco caller uses equivalent in-range padding arithmetic accepted by the released assembler.
