# Pay for sound in the frame

The previous program played a star or boost sound inside the update, so the whole game waited for it. Every update already ends by waiting for the next frame. That wait is spare time, so the sound now plays there instead of `halt`.

`start_sound` only records the sound: `sound_note` points at the current note and `sound_left` holds its remaining cycles. The main loop calls `wait_frame` where it used to `halt`. With no cycles left it halts exactly as before. Otherwise it plays the note one period at a time, reading `frames` after each period, and returns as soon as the frame interrupt has counted. The cycles still owed stay in `sound_left` for the next wait. When a note runs out it moves to the next pair; the 0 at the end sets `sound_left` to 0 and the rest of the wait just watches `frames`. Both new variables sit in the run block, so a new run starts silent. Arrival and impact still block through `play_sound`: play has ended by then, so there is no update left to delay.

The sound table is unchanged, and so is the pitch. Checking `frames` costs 24 T-states each period: `tone` ends a period with `dec e` and `jr nz` (16), while `wait_frame` uses `dec e`, `jr z,wait_next_note` not taken, `ld a,(frames)`, `cp l` and `jr z` (40). `wait_frame` takes one from each note's half-period count, which removes two delay passes, 26 T-states. A period is 26n+49 T-states, against `tone`'s 26n+51.

| Part | T-states |
|---|---|
| One period in `wait_frame` | 26n+49, including the 24-T-state frame check |
| Star notes, n=40 and 30 | 1089 and 829: 3214 Hz, 4222 Hz (`tone`: 3208, 4212) |
| Boost notes, n=100 and 70 | 2649 and 1869: 1321 Hz, 1873 Hz (`tone`: 1320, 1871) |
| Delay after the interrupt | at most one period, two at a note change: 5298 for boost |
| Time for sound in one update | 139,776 less the update's own work |

The high half is now 13n+1 T-states and the low half 13n+48. That changes the tone's colour a little, not its pitch.

Measured in Emu198x, flying the accepted keyboard route from launch and reading `frame_delta` at every update. Updates are late when `frame_delta` is above 2. The first column is the checked-in star; the others lengthen it.

| `star_sound` | sound-table, 1X / 2X | sound-frames, 1X / 2X |
|---|---|---|
| `40,8, 30,10` (4.9 ms) | 0 of 1042 / 0 of 521 | 0 / 0 |
| `40,80` (24.9 ms) | 6 late, reading 4 / 7 late | 0 / 0 |
| `40,255, 30,255` (140 ms) | 8 late, reading 8 and 10 / 8 late | 0 / 0 |

With the 25 ms star, sound-table's run took 2104 frames instead of 2092 at 1X and missed one star; at 2X it took 1064 frames instead of 1050. The new program kept 2092 and 1050 frames and the same scores every time. (The endpoint suite's boosted run, flown after a finished run and a retry, measures 1046 frames.)

What you hear. The checked-in star and boost fit inside one wait, so they sound as before: captures measured 3172 Hz and 4220 Hz over 4.8 ms for the star, and 1307 Hz and 1874 Hz over 6.0 ms for boost, against sound-table's 3163, 4187 Hz and 1312, 1866 Hz. Each starts a few milliseconds later, when the update has finished. A sound longer than the spare time is cut into pieces: the 140 ms star kept its pitches (3196 and 4199 Hz) but spread over 196 ms, with a silence of 11 to 13 ms every 40 ms while each update ran. That is a 25 Hz flutter. It is the price of never delaying the game, and short in-play sounds avoid it. Every frame boundary also stretches one half-period: the interrupt takes about 100 T-states, and on the frame between updates `wait_frame` returns and starts again, about 220 more. That is under 0.1 ms, too short to hear as a gap.

Predict, then check: change `star_sound` to `defb 40,80, 0`, as the previous program suggested. There, collecting stars made `frame_delta` read 4. Here it should stay at 2 while the star rings for 25 ms. Then try `defb 40,255, 30,255, 0` and listen for the flutter.

Space launches; O/P steer; hold Space for 2X. One hit ends the run. R retries a result; Q returns to the title. Repeat each sound: collect a star, press Space in flight, finish the course, or leave the ship still until a meteor hits it.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
