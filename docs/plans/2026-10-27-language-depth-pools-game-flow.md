# AMOS, Blitz and Ace pools and game flow

This implements the authorised language-depth tranche after the original website stack, final live checks and positive issue reconciliation complete. Produce source and website PRs for review only. Do not merge them. The existing object-pool and pools-and-states plans supply the behaviour; do not add separate checkpoint or clock features.

## Scope and workspaces

Use clean task workspaces on actual merged source/site main. Preserve the existing publisher workspaces until final publication verification finishes. Before any source edit, copy this plan into each repository's `docs/plans/` and consult its current rules and decisions. Recheck the six target paths against current main. They were positively inspected and absent at source734324e8 and website11d2acac; that does not establish absence from every lesson or a later revision.

Implement two topics, `object-pool` and `game-flow`, under each of:

- `commodore-amiga/patterns/amos/framework/`
- `commodore-amiga/patterns/blitz/framework/`
- `jupiter-ace/patterns/forth/framework/`

Website counterparts are the six matching `src/content/patterns/<machine>/<language>/framework/<topic>.mdx` paths. Use the existing catalogue/schema. Do not change lessons, dependencies, the publisher, or runtime architecture.

## 1. AMOS: qualify one topic before the next

For each topic, maintain `routines.amos`, `caller.amos`, `custom.amos`, `wrong.amos`, `repaired.amos`, `boundaries.amos`, `build.py`, `Makefile`, `README.md` and `verification/`. ASCII source is imported into AMOS Professional; do not describe an ASCII file as a saved tokenised AMOS program. Keep the small usable caller separate from generated diagnostics. Reuse existing import phases and transport with a fresh source-bound fixture.

Keep allocation in the caller and use native integer arrays/scalars. Account for inclusive DIM bounds. Component init clears its own occupancy/state only; it must not erase caller payload or initialise hardware. Give routines reserved names and state the non-reentrant ownership and normal GOSUB effects.

## 2. Blitz: independent typed implementation

Use the same topic file roles with `.bb2` sources, explicit long types and typed READ/DATA. Reuse original Ted ASCII insertion and native compile/run phases, with fresh program/media identities. Validate actual compiled execution and resource use; a generated ASCII file is insufficient. Keep window, bank, input and cleanup responsibilities in the caller. Do not inherit AMOS array layout or observer sizes.

## 3. Ace: small definitions with measured headroom

For each topic maintain `routines.fth`, `caller.fth`, `customise.fth`, `boundaries.fth`, `mistakes/`, `README.md` and `verification/`, following existing Ace source-entry conventions. State every word's stack effect, preserve values below arguments, balance the return stack on every return, and separate byte storage from two-byte cells. The original Ace manual forbids EXIT inside DO/LOOP; LEAVE takes effect at the following LOOP. Use a bounded BEGIN loop for early pool-search completion or finish the DO loop before returning; do not import an unsupported UNLOOP/EXIT idiom. Caller-created storage must remain valid while selected. No RAM injection or substitute firmware.

Measure HERE before/after each component and caller, dictionary/data-stack/CPU-stack positions during execution, and the remaining separation on the unexpanded machine. If a proposed combined observer does not fit, reduce the diagnostic workload per independent boot; do not silently increase RAM or weaken checks. Do not transfer any previous map/deadline byte count to these definitions.

## Contracts and independent cases

Pool: retain the lowest-free-slot policy, explicit full result, prevalidated release, rejected double/out-of-range release, stable indices while occupied and caller-owned payload. Qualify capacities four and eight plus the single-slot boundary. Exhaust occupancy masks for the qualified capacity, inspect every flag/payload/guard after each operation, fill to exhaustion, release/reacquire and run the optional lifetime pass without spawning inside it. Explain that released indices can become stale and that generations are outside scope. A wrong caller omits release; reacquisition then fails. The repaired caller restores the normal release path. Validate capacity/allocation contracts in the native language before computing an address; document unsupported domains explicitly.

Game flow: TITLE0, PLAY1, OVER2, PAUSED3; START1, PAUSE2, LOSS4, RESTART8. LOSS wins PAUSE; OVER/RESTART wins START. One decision per update, with no fall-through into the new state's simulation. CHANGED is an entry pulse; FRESH requests the owner's reset only on title/start or over/restart. Resume preserves session payload and input history. Invalid state or event bits preserve state and clear pulses with an explicit error result. The new native-language event domain is explicitly 0..15: reject wider or negative values before policy lookup. The old byte oracle mask `events & 240` alone is insufficient for AMOS/Blitz integers or Ace cells; include 256 and wider-bit counterexamples. Independently cover all 64 valid state/event pairs, all 252 remaining byte-valued states, upper event bits, negative and wider numeric boundaries where the language exposes them, simultaneous events, repeated/held logical events, pause/resume, loss and restart. The wrong owner resets on every entry to PLAY; the resumed session exposes the error. Custom health five versus three changes data only. This is logical-event qualification, not a new physical keyboard-reader claim.

Use existing topic-local verifier/checker/test conventions with independent host expectations. Reuse transport and pixel decoding rather than adding a general framework. Record full source/imported or compiled identity, guest-owned traversal, positive completion, complete state and guards, and actual native pixels. Corrupt code/source pins, results, completion, costs and captures to prove rejection. Keep firmware-bearing snapshots private.

## Review and publication

After each independently passing topic, commit through normal hooks and push completed work. Group the two topic commits by language into a bounded source PR and matching website PR, preserving source-first dependencies. Attach every new PR to this chat. All six routes need usable inclusion/init/calls, exact state/resource ownership, measured helper versus caller/observer costs, useful customisation, observed wrong/fixed behaviour and restrained Maths/Craft links.

Pages include maintained code through CodeFromFile and source pins. Do not imply the current publisher offers compiled downloads for ASCII/FORTH files. Run existing source checks and meaningful negative controls, complete fresh website check/build/publishing gates, and desktop/phone development and built checks for all six routes, listing/capture identities, discovery and overflow. Retain full evidence and report limits. Stop before merging the new PRs.

## Cleanup

Track each new workspace, private fixture, generated diagnostic directory and process. Before removal inspect tracked/untracked/ignored contents, verify remote retention of all unique commits, preserve evidence, stop owned processes, and use normal worktree removal. Keep unrelated edits and unknown historical workspaces intact.

## AMOS pool physical contract
Single configured pool, capacities1..8 with caller DIM PL_OP_LIVE(8); element8 is diagnostic guard outside all supported capacities. PL_OP_CAP is init input; PL_OP_SIZE is private configured count, zero before successful init. INIT clears occupancy only; invalid capacity disables context without array writes. ACQUIRE returns lowest free PL_OP_SLOT and PL_OP_OK1; full returns slot=size/OK0/error0. RELEASE validates index before subscripting, returnsOK1 on release, error2 on invalid/free slot. Invalid context error1. Payload/lifetimes remain caller-owned. Scan completes its bounded FOR loop before RETURN to avoid interpreter loop-stack leakage. Native complete mask/guard/invalid/single/custom/wrong/repaired/resource checks remain mandatory before any passing claim or PR.

## AMOS game-flow physical contract
Six native integer fields PL_GF_STATE/EVENTS/CHANGED/FRESH/ERROR/NEXT; single owner, no arrays/hardware/clocks. INIT clears context only. STEP validates state0..3 first, events0..15 next, clears pulses/error before validation, preserves invalid state/event input, ERROR1/2. NEXT holds one selected transition until final commit so no fall-through. Caller runs old-state score update first, then applies FRESH-only session reset; preserved held history computes logical byte-edge events. Wrong owner resets on every Play entry. Native byte table plus signed/wide events256/512/65535/extremes and full private state/payload observations required before qualification.

## Full native integer observability
Retain the successful768case80byte baseline before strengthening the observer. Component unchanged. New248byte records preserve full32bit integer flags and payload for all9allocated elements at INIT/acquire/release/repeat/invalid stages, plus unchanged signed invalid-slot input. This closes byte-truncation blind spots. Full190468byte observer bank is diagnostic-only, not helper RAM. Independent model and row/globalguards/pixels must agree. Falsify high flag/payload bits as well as low bytes.

## Signed minimum without an out-of-range positive literal
Preserve the passing AMOS game-flow proof before adding extremes. Build the signed minimum at runtime by assigning -2147483647 then Dec once; do not ask the original parser to represent positive2147483648 first. Five separate source-bound records observe MIN state and MIN events in each valid state, preserving all context/payload/guards. A separate native fixture avoids confusing prior positive records with the new source pins. Requalify the final complete inputs before commit.

## AMOS pool signed minimum
After preserving positive lifetime and caller proof, add six separate records: MIN capacity init, MIN configured extent acquire/release, and MIN release index at capacities1,4,8. Construct the selected field with Dec from -2147483647 before calling the unchanged helper. Observe complete context/arrays/guards; then rebuild one final source-bound fixture and requalify every variant before commit.

## Blitz physical implementation before code
Verified existing turn-deadline and tile-map sources use explicit long globals/arrays (`Dim NAME.l(upper)`), dot-prefixed labels, Gosub names without the dot, EndIf, completed For/Next loops, typed Data.l/Read and WbToScreen/Window ownership in the caller. The new framework/object-pool and framework/game-flow paths are positively absent in the task workspace. Use the agreed bounded contracts with six reserved PL_OP_ or PL_GF_ long fields; pool caller allocates nine long occupancy elements and owns payload/lifetimes. Return only after any search loop completes. Validate signed context/index/event domains before subscript/policy. Use original Ted compile/run phases in a fresh private fixture and independently measure native long arrays/scalars and diagnostic banks. Keep small caller window within the already used420x180 geometry; explicit row positions must fit all capacity8 outputs. Do not infer instruction, heap, stack or bank sizes from AMOS proof. No Blitz code/native pass is claimed by this preparatory inventory.

## Native capture exports for the paired AMOS pages
Follow the existing deadline pattern convention: derive verification/published-working.png and published-wrong.png for each AMOS topic from its retained native caller capture, and compare the website copies byte-for-byte. Verify every adjacent framebuffer column pair is identical before exporting one column per pair; preserve all unique pixels and retain original captures. Add a standard-library exporter/checker and corruption controls to the source evidence job before publishing. These are capture-format exports, not new runtime evidence or altered helper code. Native source/fixture/capture identities remain unchanged; recheck source CI at the new normal pushed head. The website uses the existing CODE_SAMPLES_PATH override locally against that exact source head. Its normal remote CI intentionally checks samples main; keep any paired website review draft dependent on source approval rather than silently changing workflow source refs or disabling checks.
