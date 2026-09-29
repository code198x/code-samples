# Give every event a sound

A sound becomes data: a list of notes, each a half-period count and a cycle count, ended by 0. One routine, `play_sound`, plays any list through `tone`. Four events now have sounds: a star collected, boost pressed, arrival in clear space and impact. Boost sounds on the press only: `boost_last` remembers the previous update's key, so holding Space stays quiet. Arrival sets the result phase first, then plays, so the run's time and score are settled before the sound starts.

`tone` loads its half-period from C with `ld b,c` (4 T-states) where the previous program used `ld b,n` (7), so a period is now 26n+51 T-states at 3.5 MHz. Cycles are counted in one byte, 1 to 255.

| Sound | Notes (n, cycles) | Pitch | Length | Measured in Emu198x |
|---|---|---|---|---|
| star | 40,8 then 30,10 | 3208 Hz, 4212 Hz | 17,038 T-states, 4.9 ms | 3150, 4200 Hz; 4.7 ms |
| boost | 100,4 then 70,6 | 1320 Hz, 1871 Hz | 21,830 T-states, 6.2 ms | 1307, 1853 Hz; 6 ms |
| arrival | 127,63; 100,79; 84,94; 62,250 | 1044, 1320, 1566, 2105 Hz | 1,046,508 T-states, 299 ms | 1041, 1316, 1561, 2098 Hz; 60, 60, 60, 118 ms |
| impact | 150,30; 200,30; 255,60 | 886, 667, 524 Hz | 676,920 T-states, 193 ms | 883, 664, 523 Hz; 34, 45, 113 ms |

Measurements count zero crossings in 44.1 kHz audio captures, so the highest pitches read slightly low.

Arrival is a rising C major arpeggio; impact falls and ends on the previous program's pitch. Each note adds under 100 T-states of table reading.

The cost is honest but not yet paid for. The game loop waits while a sound plays. An update has two frames, 139,776 T-states. A star takes about 12% of that and a boost press about 16%. The accepted routes still keep their two-frame cadence and the same times, scores and records, but that is spare time on these routes, not a guarantee. Longer in-play sounds would make updates late. Measuring that cost and spreading a sound across frames is the next program's job. Arrival and impact block for longer because play has already ended.

Predict, then check: change `star_sound` to `defb 40,80, 0` and a star should take ten times as long, about 87,000 T-states. Watch `frame_delta` while collecting stars during boost.

Space launches; O/P steer; hold Space for 2X. One hit ends the run. R retries a result; Q returns to the title. Repeat each sound: collect a star, press Space in flight, finish the course, or leave the ship still until a meteor hits it.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
