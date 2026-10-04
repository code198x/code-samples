# Let the score outgrow a byte

The previous program's score was one byte, so it could count to 255 tens of points, shown as 2550. A five-storm voyage is worth far more: on the measured keyboard route the score at each storm start read 0, 960, 1940, 500 and 1490 and the voyage ended showing 20, the true 5,140 having wrapped round twice. This program keeps the score in two bytes.

`score` and `best_score` become `defw`: a low byte and a high byte, low first, the same layout as `elapsed` and `course`. Together they count from 0 to 65,535 tens. `hud_last_score`, the HUD's copy of the score it last printed, becomes two bytes as well.

Adding to the score now uses the 16-bit add. A star's points (1 at 1X, 2 at 2X) and the finish bonus (one per second under 100) both go into DE with D at 0, and `add hl,de` adds them to the score loaded into HL. The carry out of the low byte goes into the high byte, so 255 tens plus 1 becomes 256: low byte 0, high byte 1.

Comparisons change with it. `cp` compares A with one byte; for two bytes the program subtracts. `or a` clears the carry flag and `sbc hl,de` leaves HL minus DE, setting the zero flag when they are equal and the carry flag when HL is lower. `hud` uses the zero flag to skip reprinting an unchanged score; `save_score` uses the carry flag to keep a lower score out of `best_score`.

Printing needs a new routine. `decimal3` turned a byte into three digits by subtracting 100 and 10 as often as it could. `decimal4` does the same for HL with 1,000, 100 and 10, and the units are what is left. The Z80 has no 16-bit compare, so `decimal_digit` adds a negative number instead: adding -1000 (65,536 minus 1,000) to HL carries out of bit 15 exactly when HL was at least 1,000. It counts the adds that carry; the one that does not has gone too far, and `sbc hl,bc` with the carry clear subtracts -1000, which puts the 1,000 back. Four digits cover 0 to 9,999 tens, 99,990 points. The score and best score lines gain a digit: `SCORE 05140`.

`finish_points` stays one byte: one storm's bonus is never more than 100.

Predict, then check: what does the HUD show when a star at 2X lifts the score from 255 tens to 257? The low byte goes from 255 to 1 with a carry, and the high byte from 0 to 1: 256+1, shown as `SCORE 02570`. Then change `ld bc,-10` in `decimal4` to `ld bc,-100` and predict the line for a score of 514 tens. The first two steps take out no thousands and five hundreds, leaving 14. The third now tries to take out 100 again, finds none and prints 0, so the units step is handed 14, and '0' plus 14 is the character code of `>`: the line reads `SCORE 050>0`. Each step must take out ten times less than the one before it.

Space launches; O/P steer; hold Space for 2X. One hit ends the voyage. At the result R retries from storm 1 and Q returns to the title.

Repeat: fly the whole voyage. The score climbs past 2550 without starting again; on the measured route it reads 0, 960, 1940, 3060 and 4050 at the storm starts and ends at 5140, with BEST SCORE 05140 on the result screen.

Sources: the Zilog Z80 CPU User Manual for `ADD HL,ss`, which carries out of bit 15, and `SBC HL,ss`, which sets the carry and zero flags from the 16-bit result.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
