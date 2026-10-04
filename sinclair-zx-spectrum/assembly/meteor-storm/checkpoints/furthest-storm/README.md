# Remember the furthest storm

The session records were made for one storm: the best time and the best score. On a voyage the best score no longer says much on its own. A run that dies in the third storm can outscore one that dies in the second, but a run that reaches the fifth has done something the others have not, whatever its score. This program keeps a voyage record instead: how many storms the best run crossed, and its score.

`record_crossed` (one byte) and `record_score` (one word) replace `best_score`. Like the best time, they sit outside the run's block of memory, so a retry keeps them; reloading the program clears them.

`save_record` replaces `save_score`. Its caller passes the number of storms the run crossed in A: `lost` passes `storm`, because a ship lost in storm 3 (`storm` 2) crossed two; `won` passes `storm`+1, all five. The rule has two steps:

1. `cp b` compares the record's storms with the run's. If the run crossed more, the carry is set and the run becomes the record. If it crossed fewer, the zero flag is clear and `ret nz` keeps the record.
2. If they crossed as many, the scores decide, with the same `or a` / `sbc hl,de` test `save_score` used: a lower score leaves the carry set and keeps the record; an equal or higher one replaces it.

`record_text` fills one line from the record, `BEST VOYAGE 3/5 04560`: the storms as a digit, the `/5` assembled from STORMS, and the score through `decimal4`. The result screen prints it where BEST SCORE was, under the fastest storm. The title prints it too, centred below SPACE TO LAUNCH, but only once there is something to show: `or h` and `or l` combine the storms and both score bytes, and a zero result skips the line.

Predict, then check: after a whole voyage the record is `5/5`. Retry and lose in the first storm with no stars. Which line changes? Neither the record (0 storms is fewer than 5) nor the fastest storm, which only a cleared storm can set. Then predict what happens if you swap `jr c,save_record_new` and `ret nz`... a run that crossed fewer storms would replace the record, and one that crossed more would be kept out.

Space launches; O/P steer; hold Space for 2X. One hit ends the voyage. At the result R retries from storm 1 and Q returns to the title.

Repeat: lose in storm 2 with a few stars, then press Q. The title shows `BEST VOYAGE 1/5` with that run's score. Cross more storms and it moves up; die early with more points and it stays.

Sources: the Zilog Z80 CPU User Manual for `CP r`, which sets the carry flag when the register is larger than A and the zero flag when they are equal, and `OR r`.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
