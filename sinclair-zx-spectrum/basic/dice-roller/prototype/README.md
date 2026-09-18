# Dice Roller native trial

A compact probability experiment in stock 48K PAL Sinclair BASIC. Choose a batch
of 12, 60, 300 or 1,200 simulated rolls of one die. Inspect exact counts, current
percentages as the rolls arrive, alongside the previous result's percentages. Six twenty-cell bars keep
the same 0–100% scale, rounding to the nearest five percentage points.

The live chart refreshes every roll for 12/60-roll batches and every ten rolls
for 300/1,200, plus the opening roll and exact final result.

## Controls

- Size menu: 1–4 chooses a fresh batch; Q quits to BASIC.
- Result: R starts a fresh batch of the same size; A adds that many rolls to the
  existing sample; N returns to size selection; Q quits.
- While rolling: Q stops the batch early and keeps the counts so far.

Adding stops at a maximum of 9,600 total rolls. A rejected addition preserves
both results. Added samples overlap their predecessors; previous means the last
result, not an independent experiment or a stored history. The first result
shows dashes in the previous column. The prototype is deliberately silent.

Counts always sum to the displayed sample size. Rounded percentages need not
sum to exactly 100, and a small nonzero share may have a zero-length bar. The
fair-model reference is about 16.7% per face. A finite sample does not prove a
generator fair, and a larger sample need not look more balanced on every trial.

## Reproduce

Set `EMU198X_SPECTRUM` to a built emulator with a lawfully supplied 48K ROM.
From this directory:

```sh
python3 verification/build.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence
python3 verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence
python3 verification/audit.py
"$EMU198X_SPECTRUM" --machine spectrum_48k --tape verification/evidence/dice-roller.tap --autoload-tape --scale 3
```

The builder enters complete source through ROM keyword keys and records
`SAVE "dice" LINE 10`. The checker loads the TAP in a fresh process. It reads
memory without writing it, checks totals and every displayed percentage/bar,
and exercises repeat, add, size changes, the limit, early stop, held keys and
quit. Exact zero/100% chart boundaries and an 8,400-roll starting total use labelled
ordinary ROM commands. The latter tests adding to 9,600 and refusing another
batch; its maximum-count capture is diagnostic rather than ordinary play. Captures advance fifty frames
once input is ready so a full settled video frame is presented.

Execution is configuration-specific evidence, not original-hardware timing or
player approval. The prototype is awaiting play review before lesson authoring.
