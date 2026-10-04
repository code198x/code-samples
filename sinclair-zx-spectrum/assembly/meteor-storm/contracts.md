# Contracts to explain before reuse

These are authoring notes for the runnable programs, not a substitute for teaching
how each routine works. Each checkpoint contains the routines it uses. A lesson
must link the earlier experiment or explain the implementation locally.

## Entry and clock

Code begins at 32768, disables interrupts and sets SP=$FCF0. This stack grows down;
the program and data stay below it. The private interrupt programs reserve
$FDFD..$FDFF for a JP and $FE00..$FF00 for a 257-byte vector table. They do not
borrow the ROM interrupt service or depend on its IY value. DI protects setup;
EI enables interrupts after the vector and handler are ready.

`interrupt` changes only the memory byte `frames`; AF is saved and restored.
Other primary registers are untouched. RETI completes the service, with EI
allowing the next interrupt. `interrupt-clock` isolates this from the game.
`half-rate-clock` then isolates the alternate-frame gate. This is not a general
scheduler: from `elapsed-time` on, a missed update is observable in
`frame_delta`, not silently caught up. The final game's measured work fits the intended two-frame interval.

The elapsed-frame subtraction works across one byte wrap because the unsigned
low-byte difference represents the actual gap, provided fewer than 256 frames
pass between samples. A 16-bit elapsed count wraps after 1310.72 PAL seconds;
these fixed courses finish much sooner. The formatter is scoped to their short
run times, not arbitrary hours or days.

## Pixels and artwork

`pixel_address`: D=pixel Y, E=pixel X; returns HL=bitmap byte address. Changes AF/HL;
preserves BC/DE. Split Y into its three address bit groups and X into byte column
and bit offset. This is the Spectrum bitmap layout, not a linear scanline buffer.

`next_scanline`: HL points to one bitmap byte; returns the same byte column on
the next scanline. Changes AF/HL. The low three bits of H advance within an
eight-scanline group; L and H handle the group boundary.

`draw_sprite`: D=Y, E=X, HL=shift table, A=row count. Changes AF/BC/DE/HL and two
scratch variables, `sprite_ptr` and `sprite_height`. It leaves IX unchanged.
Each shift occupies 16×4=64 bytes even when only twelve rows are drawn. The
selected offset is `(X AND 7)×64`. Each row occupies four adjacent bitmap bytes.
Callers keep X within 8..224 and the whole sprite within the screen.

XOR is its own inverse: `background XOR image XOR image = background`.
The two calls must use exactly the same image and position. Other XOR images
can overlap because XOR commutes; overwriting the background or changing a
sprite's kind before erasing breaks that contract. HUD rows and playfield rows
are separate. This renderer is not a general solution for scrolling scenery.

`ship` in the early programs toggles the image at the current `ship_x`.
From `phases` on, `erase_ship`/`draw_ship` track `ship_visible` so removal is
conditional: `draw_ship` sets it, and `erase_ship` does nothing unless it is set.
They change the primary registers and scratch state used by `draw_sprite`.

`draw_meteor`: IX=object record, D=Y, E=X. Uses the kind field to choose meteor
or star artwork when stars exist (`star-pickups` on). Draws twelve rows; changes
AF/BC/DE/HL, preserves IX. From `object-pool` on, callers save BC around it while
B is the pool loop counter.

## Input, objects and contact

`steer`: reads the O/P keyboard row; changes ship_x by two pixels within bounds.
Both held and neither held leave it alone. Changes AF/BC/DE. `boost` reads Space
and stores 0 or 1 in boost_time, representing one or two steps. It changes AF/BC.
Input is active-low; the key experiments inherited from Meet Assembly apply.

Pool records are deliberately concrete, with no hidden type system:

| Stage | Offsets, in bytes | Stride |
|---|---|---|
| object-records through fixed-course | 0 X, 1 Y, 2 active, 3 speed | 4 |
| drift | previous fields plus 4 signed drift | 5 |
| star-pickups through boost | offset 2 becomes kind (0 free, 1 meteor, 2 star) | 5 |
| render-budget onward | plus 5 previous-image X, 6 previous-image Y | 7 |

The first-dodge and phases programs use simple named variables. In
`object-records` there are three records and no pool walk: the caller points IX
at a record (`objects`, `objects+4`, `objects+8`) before each call. `spawn` fills
the record at IX from `spawn_x` and `spawn_speed` and draws it; `advance_meteor`
moves, retires and tests the one record at IX, and `advance_meteors` calls it once
per record. Both change primary registers and preserve IX.
From `object-pool` on, pool iteration uses IX as the current record and B as the
remaining slot count. `spawn` searches twenty slots, fills the first free slot and
draws it; if none is free it sets pool_overflow for verification. It changes
primary registers and IX. In `object-records` and `object-pool`, `new_game` fills
the spawn scratch variables and calls spawn three times. From `fixed-course` on, `waves` reads the next event when its countdown
expires, fills the same variables and calls spawn. Event strides are three bytes,
then four with drift, then five with kind. Bounds and record sizes are visible
in each source.

From `object-pool` on, `advance_meteors` loops over all active slots; changes primary registers, IX and
object/run state. It retires an object at y>=174. Contact requires 154<=y<172
and abs(object_x-ship_x)<16. Equality at 16 is a miss. Kind determines whether
contact removes the ship's one life or adds score. Removal clears kind/activity,
so the same star cannot award points twice. This is an intentionally forgiving
inset rectangle rule, not a claim that every lit pixel collides.

`count_objects` counts occupied slots; despite its prototype ancestor's name it
does not draw anything. It changes AF/B/DE/IX and active_count. In
`object-records` there is no count: the run is complete when the three active
bytes are all zero. In `object-pool` a zero active count completes the run; from `fixed-course` on, completion requires
both event exhaustion and a zero active count. Both come after checking for a
fatal hit.

## Phases

From `phases` on, `phase` is 0 at the title, 1 in flight, 2 after destruction and
3 in clear space. From `debris` on, phase 2 begins with the destroyed phase (see below). `title` sets phase 0, clears the screen, draws its lines and
waits for Space between two calls to `release_keys`. `phases` through `records`
place the title lines at hand-counted columns; `finished` centres them with
`text_center`. In flight, Q leaves for `title`. `hull` is 1 while the ship is
alive; contact clears it and the main loop leaves for `lost` when it reads zero.
The name survives from an earlier multi-hit prototype; one contact ends the run.
`lost` and `won` set phase 2 or 3 and share `result`, which clears the screen,
draws the outcome and waits: R calls `new_game`, Q returns to `title`. Each
result waits for key release first, so a key held from flight cannot choose.

## Text, numbers and lifetime

`text`: B=character row, C=column, DE=zero-terminated ASCII. Copies glyphs from the
ROM font, without ROM calls or print state. Changes all primary registers. Stops
at row 24 or column 32. Used strings are printable ROM characters; this is not a
control-code parser. `text_center` measures the actual string, computes
floor((32-length)/2), and passes that column to text. Overlong strings start at
column zero and are clipped.

`decimal3`: A=0..255, HL=three output bytes. Writes hundreds, tens, units by
repeated subtraction. Changes AF/B/HL. It arrives in `stars`; in `star-pickups`
the score byte exists but is only inspected. Score stores tens of points; its buffer
has a fourth, fixed '0'. Do not confuse that representation with four-digit
arithmetic. One storm's maximum is bounded below byte overflow; from `voyage` on,
five storms are not, and the score wraps past 255. From `two-byte-score` on
`score`, `best_score` and `hud_last_score` are words, low byte first.

`decimal4` (from `two-byte-score`): HL=0..9999, DE=four output bytes. Writes
thousands, hundreds, tens and units. Changes AF/BC/DE/HL. `decimal_digit`:
BC=minus a power of ten, HL=value, DE=output; adds BC while it carries,
counting from '0', undoes the last add with `sbc hl,bc` (carry clear), writes
the digit at DE and advances DE. Above 9999 the thousands digit passes '9'; the
voyage's score stays well below that. `save_score` compares words with
`or a` / `sbc hl,de` and changes AF/DE/HL.

`seconds` and `format_time` arrive in `timed-course`; `elapsed-time` measures
`elapsed` without displaying it. `seconds`: HL=elapsed PAL frames; returns A=whole seconds, L=remainder, H=0;
changes AF/B/DE/HL. The current short-course use stays below 256 seconds.
`format_time`: HL=frames, DE=SS.CC buffer with one writable padding byte before
it; changes primary registers and scratch bytes. Explain that padding contract
before reusing the routine: decimal3 writes three digits and the leading one
lands in the pad. This is limited to the game's sub-100-second display.

`new_game` clears the screen and state_start..state_end, then sets the non-zero
starting values: phase 1, the ship and `hull`, then what the stage has: the one
meteor (`phases`), three spawns (`object-records`, `object-pool`) or the first
event countdown (`fixed-course` on), the HUD (`stars` on) and the frame baseline
(`elapsed-time` on). It changes primary registers and IX. Session records (`records` on) live
outside this range. `save_score` changes AF/B and replaces best_score only
when this run is at least as high. A successful finish additionally considers
best_time; a failed run cannot replace it. All records are RAM state, lost on
program reload. `release_keys` waits for Space, Q and R to be released and changes
AF/BC; it prevents a held launch/retry key from triggering the next phase.

## Sound

Port $FE bit 4 drives the speaker and bits 0-2 set the border; bit 3 (MIC) stays
0. From `tone` onward the border colour lives in `border`, outside the run state,
and every speaker write ORs it in, so a sound never changes the border. Start-up
writes it once. Up to sound-table, sounds block: interrupts still count frames,
but the program waits until the sound ends. From sound-frames, star and boost
play during the wait for the next frame instead, and from debris the impact
does too. Timings assume 3.5 MHz and code above $8000, where
only each OUT to the ULA port can be delayed by contention.

`impact_sound` (tone checkpoint): no inputs. Plays IMPACT_CYCLES periods of
26×IMPACT_HALF+57 T-states, 105 cycles of 6687 (523 Hz, 200.6 ms). Changes AF/B/DE.
IMPACT_HALF 0 would mean 256 passes; keep it 1-255, and IMPACT_CYCLES 1-255.

`tone` (sound-table onward): D=border bits, C=half-period count 1-255, E=cycle
count 1-255. Period 26×C+51 T-states. Changes AF/B/E; preserves C, D and HL.
The two halves differ by 23 T-states; pitch follows the whole period.

`play_sound`: HL=sound, a list of (half-period, cycle count) byte pairs ended by
a 0 half-period. Reads `border`, plays each note through `tone`. Changes
AF/BC/DE/HL; preserves IX. Callers inside the pool loop save BC. In sound-table, sounds played
during an update (`star_sound`, `boost_sound`) must stay short: the update has
139,776 T-states and they take about 17,000 and 22,000. `arrival_sound` and
`impact_sound` play after the run's result is decided.

`boost` also plays `boost_sound` when Space is held now and was not at the
previous update. `boost_last` holds that previous state inside the run range, so
a new run starts with it clear. Changes AF/BC/DE/HL (sound-table); from
sound-frames it starts the sound instead and changes AF/BC/HL.

`start_sound` (sound-frames onward): HL=sound, in `play_sound`'s format. Records
it in `sound_note` (current note address) and `sound_left` (cycles still to play
in that note), replacing any sound already due. Plays nothing itself. Changes
A/HL; preserves BC, DE and IX, so the pool loop calls it without saving BC.

`wait_frame` (sound-frames onward): replaces the main loop's `halt`. Returns once
`frames` has changed since entry, as `halt` would. With `sound_left` 0 it is a
`halt`. Otherwise it plays the current note from `sound_note`, one period of
26×n+49 T-states at a time (n=half-period, 2-255: it uses n-1 delay passes to
pay for the 24-T-state frame check), reading `frames` after each period. It
saves the cycles left and returns within one period of the interrupt, two at a
note change. A 0 half-period ends the sound: `sound_left` becomes 0 and the rest
of the wait polls `frames`. Reads `border`; changes AF/BC/DE/HL/IX. A sound that
outlasts one wait continues in the next, silent while the update runs.
`sound_note` and `sound_left` are in the run range, so a new run starts silent.
`arrival_sound` and `impact_sound` still block through `play_sound`; from `debris`,
`impact_sound` is started with `start_sound` at contact and plays during the
destroyed phase's frame waits, while `arrival_sound` still blocks.

## Destroyed phase

From `debris` on, contact clears `hull`, starts `impact_sound` and leaves the meteor
in its slot and on screen; the main loop then jumps to `destroyed` instead of `lost`.
`destroyed` sets phase 2, sets `border` to FLASH_BORDER (2, red) and writes it to
port $FE, calls `erase_ship`, copies DEBRIS (8) four-byte records from
`debris_start` to `debris` and sets each X to `ship_x`. Records are 0 X, 1 Y,
2 signed dX, 3 signed dY; stride 4. It draws them, sets `debris_time` to
DEBRIS_UPDATES (25) and runs that many updates on the main loop's even-frame gate:
`draw_debris` (erase), `move_debris`, `draw_debris` (draw). When `debris_time`
reaches DEBRIS_UPDATES-FLASH_UPDATES (22) it sets `border` to 0 and writes it, so
the border is black again before the result and for every later run. It reads no
keys and never updates the pool, `ticks` or `elapsed`. It then falls into `lost`.

`debris_sprites` holds eight shift tables of 512 bytes, one per piece, generated by
`assets.py` from the ship artwork: three bands of five ship rows (from rows 1, 6
and 11), the first split into two column ranges and the others into three. Each
piece keeps its columns in the 24-pixel frame, so drawn at the ship's X and its
band's row the eight pieces reproduce the ship exactly.

`draw_debris`: no inputs. XORs piece n with `draw_sprite`, DEBRIS_ROWS (5) rows of
the nth table from `debris_sprites`, at record n's X and Y. Changes AF/BC/DE/HL/IX.
`move_debris`: no inputs. Adds dX; a new X outside 8..224 is not stored, so the
piece keeps its X. Then adds 1 to dY (gravity) and dY to Y. A new Y above
DEBRIS_FLOOR (179) is replaced by 179 and dX becomes 0: the piece has landed, and
its five rows end at y=183, above the controls line. With the starting dY of
`debris_start` (-12 at the most) Y stays within 100..179 and never wraps.
Changes AF/BC/DE/IX.
`debris_time` and `debris` are in the run range.

## Colour

`clear`: no inputs. Zeroes the bitmap at $4000-$57FF, then writes the attribute
map at $5800-$5AFF, 24 rows of 32 bytes. Up to `debris` it writes $47 (BRIGHT
white INK on black PAPER) to every cell, then $45 (BRIGHT cyan) to the first 64,
the top two rows. From `colour-bands` on it reads one byte per character row
from `row_colours`, top row first, and writes it to all 32 cells of that row.
Changes AF/BC/DE/HL. An attribute byte is FLASH (bit 7), BRIGHT (bit 6), PAPER
(bits 5-3) and INK (bits 2-0); every byte in the table is $40+INK.

Nothing else writes attributes: the sprite and text routines change only the
bitmap. The colours therefore belong to places, not objects, and last until the
next `clear` (the title, `new_game` and `result`). Every object in a row shows
that row's INK on black PAPER, so objects cannot clash; a sprite across a row
boundary shows each row's colour on its side of the line. `row_colours` sits
outside the run range. A per-object colour would break this contract: the
colour would stay with the cell, not follow the object.

## Voyage

From `voyage` on, `assets.py` emits five event tables, `course_1` to `course_5`,
each 120 events of five bytes, from seeds 1986 to 1990. `courses` lists their
addresses (two bytes each, low byte first) in storm order; it sits outside the
run range. The run range holds `storm` (0 to STORMS-1) and `course`, the address
of the current table, which `waves` reads in place of the fixed `meteor_events`.

`start_storm`: no inputs. Reads `courses` at `storm`×2 into `course`, then sets
`wave` 0, `wave_timer` 20, `ticks` 0, `elapsed` 0 and `ship_x` 116. It leaves
score, phase, hull, records and the screen alone. Changes AF/DE/HL. `new_game`
calls it after clearing the run range; `storm_cleared` calls it after adding 1
to `storm`. The caller erases and redraws the ship around it.

`storm_cleared` replaces `won` as the main loop's exit for clear space. It adds
the finish bonus and keeps a faster `best_time` (the fastest storm, since
`elapsed` restarts each storm), then plays `arrival_sound`. At the last storm it
falls into `won`, which now only calls `save_score`, sets phase 3 and shows the
result. Before it, it draws CLEAR SPACE, the bonus line and NEXT STORM, halts
INTERLUDE_FRAMES (100) times, writes 32 spaces from column 0 over rows 8, 12
and 15, then starts the next storm and redraws the HUD with `hud_drawn` at 0.
The interlude reads no keys and leaves `last_frame` at the frame the next storm
starts, so it adds nothing to `elapsed`.

`hud` with `hud_drawn` at 0 also writes `storm`+'1' into `storm_digit` and draws
`storm_text` (`STORM n/5`, the 5 assembled from STORMS) at row 0, column 22.

From `storm-bonus` on `storm_cleared` adds `finish_points` to `score` `storm`+1
times (`djnz`, B from 1 to 5), so one storm adds at most 495 tens. `start_storm`
also sets `finish_points` to 0. `bonus_line` writes `storm`+'1' into
`bonus_storm`, then prints `FINISH BONUS nnn0 Xn` at row 12, column 5.
