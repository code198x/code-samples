# Reward each storm cleared

Until now each storm's finish bonus was the same deal: one point, shown as ten, for each second under 100. A fast fifth storm was worth no more than a fast first one, although the player had to survive four storms to reach it. This program multiplies each storm's bonus by the storm's number: ×1 for the first, ×5 for the fifth.

The Z80 has no multiply instruction. Multiplying by a small whole number is repeated addition, and the multiplier here is never more than five, so `storm_cleared` adds the bonus to the score once for each storm so far:

```asm
 ld e,a          ; the bonus, 0-99
 ld d,0
 ld a,(storm)    ; 0 for the first storm
 inc a
 ld b,a          ; 1 to 5 additions
 ld hl,(score)
bonus_add:
 add hl,de
 djnz bonus_add
 ld (score),hl
```

`djnz` counts B down and repeats until it reaches zero, so the loop runs `storm`+1 times. The largest bonus, 99 for a storm under a second, times 5 adds 495 tens: the two-byte score from the previous program has room.

The bonus line names the multiplier: `FINISH BONUS 0800 X3`. `bonus_line` writes `storm` plus the character code of '1' into `bonus_storm` before printing, as `hud` does for `STORM 3/5`. `start_storm` sets `finish_points` to 0, so a result after a hit shows no bonus for the storm the ship was lost in, rather than the bonus of the storm before. The title's bonus line now reads `FAST FINISH: BONUS X STORM`.

The interlude shows the bonus before the HUD does: the bonus is added straight away, but the HUD's score line is only redrawn when the next storm starts.

Predict, then check: on the measured keyboard route the five storms take 20, 20, 20, 21 and 19 whole seconds, for bonuses of 80, 80, 80, 79 and 81. What do the multiplied bonuses add over the previous program's 514 tens? 80×0 + 80×1 + 80×2 + 79×3 + 81×4 = 801 more, 1,315 tens: the voyage ends at 13150. Then change `inc a` before `ld b,a` to `add a,a` and predict the first storm's bonus. `storm` is 0, so B is 0, and `djnz` takes 1 from B before testing it: 0 becomes 255, not zero, and the loop runs 256 times. A bonus of 80 adds 20,480 tens, more than `decimal4`'s 9,999, so the score line's first digit runs past 9 into other characters.

Space launches; O/P steer; hold Space for 2X. One hit ends the voyage. At the result R retries from storm 1 and Q returns to the title.

Repeat: fly the voyage and watch the interludes: `X1`, `X2` and so on, with the score jumping by the bonus times that number when the next storm starts.

Sources: the Zilog Z80 CPU User Manual for `DJNZ`, which decrements B and jumps unless the result is zero.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
