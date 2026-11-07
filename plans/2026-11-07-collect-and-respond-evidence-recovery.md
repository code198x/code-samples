# Finish collect-and-respond evidence recovery

Recover the six inherited assembly capability records under batch 8b of
`2026-11-06-evidence-byte-check.md`. Preserve their observations and captures.

## Approved audio versions

On 7 November 2026 Steve explicitly approved keeping the matching audio
versions for this batch, with tracked investigations: Amiga 0.44.1,
BBC Micro and NES 0.45.1, and Electron 0.44.2. C64 and Spectrum reproduce
with 0.48.3. This approval preserves evidence; it does not establish the
cause of audio differences or authorise accepting changed measurements.
Retain Asm198x 0.0.75 and Build198x 0.2.13; root pins and replay are later
steps in the agreed plan.

## Steps and verification

1. Recover `scripts/verify-collect-and-respond.py` and the six records
   unchanged from the durable inherited patch. Add composition and Electron
   registration and optional Build198x support to
   `scripts/check-capability-coverage.py`, preserving hardware registration.
2. Add distinct composition tests to `scripts/test_capability_coverage.py`.
   Keep all hardware tests. Prove comments leave bytes unchanged, changed
   operands and forged programs fail, and absent recorder registration fails.
3. Refresh the six record digests and released executable identities in
   `docs/capability-coverage.json`. Register the recorder and its approved
   exceptions in `plans/2026-11-07-evidence-recorders.json`, with observational
   audio follow-ups and an evidence-backed condition for removing each pin.
4. Run complete capability and probe inventories, both unit suites, Ruff
   and diff checks. Compare all original observations and evidence files.
   Push a reviewed PR and require full fresh CI before merge.
5. Preserve unfinished inherited workspaces and the original patch. Remove
   the task-owned workspace and generated caches after remote retention.

## Fresh matching-release reproduction

All six runs passed independently with the recorded tools before integration.
Spectrum included fresh-ROM tape loading, and Electron was selected explicitly.
All ten program digests, 13 screenshot bytes, six full WAV hashes and six
excerpt PCM comparisons matched. Every disabled-collection control failed
the same collection guard used for its positive run. Each run exited zero
within 34 seconds. No observation was refreshed to accept a difference.

## Independently reproduced audio endpoints

The four newer-release runs also exited zero and rejected their collection
negatives. Program digests, screenshot bytes and all non-audio observations
matched; full WAVs and excerpt PCM differed. All captures use 48 kHz PCM.

| Machine | Matching release / frames | 0.48.3 frames | Follow-up |
|---|---|---:|---|
| Amiga | 0.44.1 / 90095 | 86261 | [2322](https://github.com/emu198x/emu198x/issues/2322) |
| BBC Micro | 0.45.1 / 87221 | 87220 | [2323](https://github.com/emu198x/emu198x/issues/2323) |
| Electron | 0.44.2 / 89137 | 89137 | [2324](https://github.com/emu198x/emu198x/issues/2324) |
| NES | 0.45.1 / 73479 | 74278 | [2325](https://github.com/emu198x/emu198x/issues/2325) |

Electron's unchanged length and amplitude range do not mean unchanged PCM:
its AC power and full/excerpt PCM bytes differ. The underlying causes remain
unknown. No audio result establishes pitch accuracy or hardware conformance.
