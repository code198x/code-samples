# Give each meteor its own record

Replace `meteor_x` and `meteor_y` with three four-byte records at `objects`: X, Y, active, speed. `SLOTS equ 3` sizes them with `defs SLOTS*4`. `new_game` points IX at each record in turn (`objects`, `objects+4`, `objects+8`), sets `spawn_x` and `spawn_speed`, and calls `spawn`, which fills the record at IX and draws it. `advance_meteors` makes one explicit call to `advance_meteor` per record, with IX pointing at that record; `(ix+1)` is always the current record's Y. An inactive record is skipped. The run is won when all three active bytes, at `objects+2`, `objects+6` and `objects+10`, are zero, after the hull check.

Predict, then check: after launch the twelve bytes at `objects` read 80,24,1,2, 116,24,1,3 and 170,24,1,4. Each update adds a record's speed to its Y. Speed 4 retires on update 38 (24+4×38=176), speed 3 on update 50 and speed 2 on update 75; each active byte drops to 0 in that order, and CLEAR SPACE follows 75 updates (three seconds) after launch. Change the third call's `ld ix,objects+8` in `advance_meteors` to `ld ix,objects+4`: the X=116 meteor now moves twice per update, and the X=170 meteor hangs at the top, so the run never reaches CLEAR SPACE.

Space launches; O/P steer. One hit ends the run. R retries a result; Q returns to the title, in flight or at a result.

Repeat: R at a result starts the same run again from a cleared state; Q then Space starts it from the title.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
