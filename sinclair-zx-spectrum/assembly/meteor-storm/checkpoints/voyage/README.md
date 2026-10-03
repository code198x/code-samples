# Chain storms into a voyage

Until now, reaching clear space ended the game. This program turns one storm into a voyage of five: clear space leads into the next storm, and only the fifth one ends in the result screen. One hit still ends the run, wherever it happens.

Each storm is an event table like the one the game already reads: 120 events of five bytes (X, speed, delay, drift, kind), 600 bytes per storm. `assets.py` makes the first table from seed 1986, as before, and four more from seeds 1987 to 1990 with the same rules, so the later storms are new courses with the same speeds and density. The tables are labelled `course_1` to `course_5`, and a second table lists their addresses in order:

```asm
courses: defw course_1,course_2,course_3,course_4,course_5
```

`waves` used to read `ld hl,meteor_events`, a fixed address. Now it reads `ld hl,(course)`, a two-byte variable holding the address of the current storm's table. Changing storms is changing that one pointer. `start_storm` doubles `storm` (each address in `courses` is two bytes), adds it to `courses`, and copies the address it finds there into `course`. It then restarts the course itself: `wave` to 0, the first spawn 20 updates away, `ticks` and `elapsed` to 0, and the ship back to the centre. `new_game` calls it for the first storm; `storm` and `course` sit in the run block, so a retry starts at storm 1 again.

When the last event has spawned and the playfield is empty, the main loop jumps to `storm_cleared` instead of `won`. It does what `won` did for the finish: the bonus (one point, shown as ten, for each second below 100) goes onto the score, and a time faster than `best_time` replaces it. Because the clock restarts each storm, `best_time` is now the fastest single storm, and the result screen calls it `BEST STORM`. Then:

- After the fifth storm (`storm` is STORMS-1) it carries on into `won`, the result screen, as before.
- Before that, it plays the arrival sound, shows CLEAR SPACE, the finish bonus and NEXT STORM for 100 frames (two seconds), overwrites those three lines with spaces, adds 1 to `storm`, calls `start_storm`, redraws the ship and the whole HUD, and goes back to the main loop.

The HUD gains `STORM 1/5` at the right of the top row. Its digit is written into the string before it is drawn: `storm` plus the character code of '1'. The `/5` is assembled from STORMS, so changing the constant changes the display too.

The score has not changed: it is still one byte, so it can only count to 255 (shown as 2550). Five storms are worth far more than that. On the measured keyboard route the score at the start of each storm reads 0, 960, 1940, 500 and 1490, and the voyage ends showing 20. The true total is 5,140 points; the byte has wrapped round twice. The next unit gives the score a second byte.

Predict, then check: change `STORMS equ 5` to `STORMS equ 2`. The HUD shows `STORM 1/2`, and the result arrives after the second storm. The `courses` table still lists five courses; the program never reads past the second. Then put it back and change `courses` to `defw course_1,course_1,course_1,course_1,course_1`: five passages through the first storm, every one the same.

Space launches; O/P steer; hold Space for 2X. One hit ends the voyage. At the result R retries from storm 1 and Q returns to the title.

Repeat: launch and leave the ship still. The first meteor hits the ship about 2.2 seconds after launch, and the result shows `STORM 1/5`. Cross a storm and the next starts with the clock at 00.00 and the ship back in the centre.

Sources: the Zilog Z80 CPU User Manual for `ld hl,(nn)` and `ld (nn),de`, which load and store a register pair from two consecutive bytes, low byte first.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
