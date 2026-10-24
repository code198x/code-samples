# C64 rectangle overlap

Two boxes share area in `demo`; moving B so its left edge equals A’s right edge in `custom` changes the result to zero. The screen shows A, B and X for shared cells. The first digit is the collision result. Run `make`, load `build/demo.prg`, type `RUN`, and reset to leave. Asm198x 0.0.72 builds these callers.

## Use the routine

Reuse `../../framework/collect-and-respond/collision.inc` unchanged. Include it once, outside the fall-through path. Write four unsigned **edge coordinates** into each of `rect_a` and `rect_b`: left, top, right, bottom. Call `boxes_overlap`. Carry set means overlap; carry clear means apart or empty. A and flags change; X and Y survive. There is no initialisation, allocation or I/O. The routine owns eight bytes of rectangle state and uses the caller’s normal JSR stack. Copy inputs before each call; keep interrupt handlers from changing them during it.

```asm
    lda #2
    sta rect_a       ; left
    sta rect_a+1     ; top
    lda #8
    sta rect_a+2     ; right, excluded
    lda #6
    sta rect_a+3     ; bottom, excluded
    ; Fill rect_b too, then:
    jsr boxes_overlap
    bcc no_hit
    ; Handle a hit here.
```

Edges must fit 0–255. Right and bottom are excluded, so [2,2,8,6] covers six by four coordinate units. Touching edges do not share area. Zero or reversed extents return false. The routine performs no addition: when starting from position and size, form right/bottom with wider arithmetic and reject or clip out-of-range results **before** storing bytes. A full 320-pixel C64 screen needs a wider coordinate representation; this helper does not silently support it. Grid cells and a translated local region are suitable domains.

The helper costs 68 instruction bytes plus eight data bytes. Its early exits make execution depend on the inputs. The standalone demo is 2,085 payload bytes, including 184 supplied test cases, results and a diagnostic renderer: that is not the cost of collision alone. No cycle budget or physical-machine qualification is claimed. Box collision is a useful broad phase before a smaller number of mask/pixel checks; those still need their own implementation and budget.

## Customise and diagnose

Change the data in `custom.asm`, rather than editing the algorithm. Smaller boxes can make a player more forgiving; larger interaction boxes can make an item easier to collect. Keep rendering coordinates separate from the collision contract. The demo grid is only 40×10 cells; the arithmetic helper is not limited to that viewport.

`wrong-touch.inc` deliberately accepts equality in the four separation checks. In `wrong`, adjacent A/B cells have no X cells, yet the digit says 1. Restore the original comparisons: `repaired` uses exactly the same geometry and executable payload as `custom`, and says 0. Empty and reversed boxes remain rejected in the fault, making its symptom specific.

`caller.inc` also supplies 184 independent cases from the shared interval-intersection oracle. This is a second, guest-owned caller; the observer does not write results or set the PC. It checks both argument orders, maxima and deterministic generated boxes, and tests preservation of Y while X indexes results. Completion guards distinguish a stopped program from a successful run.

## Qualification

`verification/results.json` binds sources, the released emulator/assembler, stock ROM hashes, the full imported program before RUN, outputs and four PNGs. PAL C64 Emu198x 0.44.2 is the selected native configuration; firmware is not redistributed. The checker compares every result with an independent max/min interval oracle and every diagnostic glyph with the native PNG. Tests corrupt the evidence and image expectations to establish that the gate can fail.

```sh
python3 scripts/check-c64-rectangle-overlap.py
python3 -m unittest discover -s scripts -p test_c64_rectangle_overlap.py -v
```

Run these from the repository root. Re-capture using `scripts/verify-c64-rectangle-overlap.py` with explicit `--assembler`, `--emulator` and `--firmware` paths. No physical C64 timing or hardware compatibility beyond the recorded configuration is established by this evidence.
