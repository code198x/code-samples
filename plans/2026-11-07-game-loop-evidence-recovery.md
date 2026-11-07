# Finish the frame-paced probe evidence batch

Recover #458 after the hardware and Sega batches, retaining each recorder
registration and the observation-integrity checks added by #456.

## Approved emulator pins

On 7 November 2026 Steve answered the coordinator's pin question:
"Keep those versions for this batch, then investigate the timing changes
(Recommended)". This approves Amiga 0.44.1 and BBC Micro 0.45.1 for this
batch, preserving the original observations. It does not approve replacing
measurements with newer values or classify the timing differences as bugs.
Track each timing investigation with the precise observations and undo the
pin after an evidence-backed ruling and re-record.

## Steps

1. Replay #458 onto the hardware/Sega result, retaining all recorder
   inventory entries and both existing probe test classes. Add the
   frame-paced recorder and its failure controls, and pin the six updated
   probe records in `docs/probe-coverage.json`.
2. Verify the six original record files and recorder are unchanged from
   #458. Independently run `test_probe_coverage.py` and the complete
   checker against the pinned registry. Confirm comments pass and changed
   operands, forged programs and altered observations fail. Run Ruff and
   `git diff --check`; check the capability inventory still passes.
3. Reproduce the Amiga and BBC observations with the recorded released
   tools and existing firmware. File observational timing follow-ups and
   replace the pending-ruling notes with their links.
4. Once #461 lands, put this batch on fresh main, push a replacement PR,
   and require fresh CI before merge. Close #458 only after the replacement
   is retained and reviewed. Preserve the separate collect-and-respond
   recovery patch and remove the task workspace after remote retention.

## Independent endpoint reproduction

Using the same Asm198x 0.0.75 programs and firmware, the recorder reproduced:

| Machine | Release | Normal / over-budget / recovered (30 frames) | Unpaced (10 frames) |
| --- | --- | --- | --- |
| Amiga | 0.44.1 | 30 / 5 / 30 | 3421 |
| Amiga | 0.48.3 | 30 / 6 / 30 | 3219 |
| BBC Micro | 0.45.1 | 30 / 10 / 30 | 191 |
| BBC Micro | 0.48.3 | 30 / 10 / 30 | 205 |

Every run rejected its unpaced negative control. The timing causes remain
unknown. Follow-ups: [Amiga](https://github.com/emu198x/emu198x/issues/2318)
and [BBC Micro](https://github.com/emu198x/emu198x/issues/2319). The prior
sweep's intermediate-release observations are distinguished from these
independently reproduced endpoints in each issue.
