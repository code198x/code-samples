# Tail Chase: compare body representations

Keep the original unit 04, 05 and 06 sources. This companion reads their retained execution records; it does not change a game or launch an emulator.

Run from this directory:

```sh
python3 compare.py
```

The script checks source and tape hashes against each record, compares all 64 recorded movement/rejection events from `shifted-body` and `circular-body`, and checks the common opening of the two unit 06 growth checkpoints. `results.json` retains its output. Slot numbers are reconstructed using the source's index rules; body coordinates are from the recorded emulator observations. They are different kinds of evidence.

The original runs used Emu198x Spectrum 0.25.0 and a stock 48K PAL ROM. See [reproduction and limitations](../README.md#recorded-execution). This comparison is not a new native run, hardware test, performance measurement or proof of every route.

## Read the trace before the explanation

The recorded route begins with J (ignored reversal), X (irrelevant input), then twelve K/J/I/L loops, then straight movement to a rejected wall move. Each key is associated with one attempted move, not one display frame. Both first moves therefore continue right.

Predict the live slots after moves 8 and 9. Then compare `wrap_examples`: move 8 uses 9,10,11,12; move 9 uses 10,11,12,1. Coordinates remain in tail-to-head order even though physical indices wrap. Move 12 wraps the tail as well. All 64 recorded events agree between the shifting and circular checkpoints, including the final rejected move.

Unit 06 is a new rule, not another equivalent implementation of unit 04. Both unit 06 checkpoints match the first two ordinary moves; their third move retains (8,8) and adds (8,12), producing five cells. The diagnostic then takes K/J/I. I is rejected and the body stays unchanged. The normal one-food checkpoint stops after eating and cannot perform that final test.

The lesson's stopped-program inspection uses a simpler straight route. Its coordinates intentionally differ from this turning trace. It tests the same head/tail index boundaries without requiring accurately timed turns. STOP and PRINT disturb timing: use this exercise for state inspection only, remove its temporary line and RUN the original again afterwards.

## Explain the trade-off

At length four the shifting source copies three coordinate pairs and writes the new pair. The circular source writes one pair and updates indices. It allocates twelve coordinate pairs rather than four and must distinguish live slots from stale values. Neither the trace nor those assignment counts establish whole-game speed. Collision scanning, drawing, input and the movement threshold still matter.

Growth is supported only by unit 06 here. No extra shifting-growth implementation, BASIC performance port, generic container or timing benchmark has been added.
