# Break the ship apart

In the previous program a hit played the impact sound and then `result` cleared the screen at once, so the player never saw what hit them. Now contact starts a short destroyed phase. The border flashes red, the storm stops where it is but stays drawn, and the ship comes apart into eight pieces that are thrown up and fall back for one second before the result appears.

The pieces are cut from the ship's own artwork. `assets.py` splits the ship's rows into three bands, each five rows tall: the nose in two halves, the middle in three (left wing, centre, right wing) and the tail in three. Each piece keeps its columns within the ship's 24-pixel frame and becomes its own 512-byte shift table, one after another from `debris_sprites`. Together the eight pieces are exactly the ship, pixel for pixel, and each has 8 to 20 lit pixels.

`destroyed` sets `phase` to 2 and the border to `FLASH_BORDER` (red), erases the ship and copies eight debris records from `debris_start`. Each record is four bytes: X, Y, dX and dY. They use the fixed offsets of unit 12's object records, and unit 13's pool walk visits them: IX points at the current record and B counts the pieces. Every piece starts at the ship's X, and its Y is the ship row where its band begins, so the first `draw_debris` puts the ship back exactly where it was. `draw_debris` steps HL on by 512 bytes for each record, so record n draws with piece n's table.

Then `destroyed` runs its own loop of `DEBRIS_UPDATES` (25) updates at the main loop's rate. It waits with `wait_frame`, skips odd frames as the main loop does, and each update does the three familiar steps: `draw_debris` erases every piece, `move_debris` moves them, and `draw_debris` draws them again. XOR makes one routine do both jobs, and pieces pass over frozen meteors without damaging them. When the count reaches zero the program falls into `lost` and the result as before; `result` clears the screen, so no piece survives it.

`move_debris` adds dX as before: a piece that would leave X 8..224 keeps its X, drift's bounds idea. Then gravity: it adds 1 to dY every update, then adds dY to Y. The centre piece starts at dY=-12, so its first move is -11: it rises 11, 10, 9 ... 1 pixels, 66 in all, hangs for one update, and is back at its starting height after 23 updates. The nose pieces start at -11 (55 pixels up), the wings at -8 (28), the tail pieces at -4, +1 and -4. The highest point is y=100, well below the HUD. `DEBRIS_FLOOR` (179) is the lowest Y a piece may have: its five rows then end at y=183, just above the controls line at 184. A piece whose new Y would pass the floor lands on it, and its dX becomes 0 so it stays there. Y never wraps: the lowest Y is 100 and the fastest fall (dY 26) starts from at most 179.

The flash uses unit 24's `border`. Setting it to red and writing it to port $FE turns the border red at once, and every speaker write of the impact sound ORs `border` in, so the border stays red while the sound plays. After `FLASH_UPDATES` (3) updates `destroyed` sets `border` back to 0 and writes it. `border` lives outside the run block, so that restore is what makes the result and every later run start black.

The meteor that hit keeps its slot and its image (`meteor_contact` jumps to `advance_meteors_skip` instead of removing it), so it sits where the ship was. The run is over, so the extra active slot changes nothing: `new_game` clears it with the rest of the run block. The impact sound goes through `start_sound`, so the frame waits of the destroyed phase play it while the pieces fly. Blocking first would hold the pieces still for about 193 ms (ten frames).

| Part | Measured in Emu198x |
|---|---|
| Destroyed phase | 50 frames (25 updates, one second) from contact to the result |
| Border flash | red for 6 frames (3 updates), then black |
| Highest piece | y=100; all eight pieces land on y=179 in the centre run |
| Impact notes | 882, 668 and 525 Hz (computed 886, 667 and 524) |
| Impact length | 241 ms from first to last edge, against 193 ms of tone |
| Gaps in the impact | six silences of about 8 ms, one per update, 40 ms apart |

Those gaps are the price of drawing sixteen sprites per update (each piece erased and redrawn) while the speaker waits: the same 25 Hz flutter the previous program described for long sounds, but deeper, so the crash rattles. Arrival is unchanged: it still blocks through `play_sound` and cuts straight to the result, so destruction and arrival stay distinct.

`debris_time` and `debris` sit in the run block, so a retry starts with no debris. The destroyed phase reads no keys: R and Q do nothing until the result, and a key still held when the result appears waits for release first, as before. Flight, collision, scoring and the course are unchanged. The accepted keyboard routes finish with the same frames, times and scores, and a run that ends in contact reaches its result about a second later.

Predict, then check: delete the first `call draw_debris` after `jr nz,destroyed_wait`, so pieces are drawn but never erased. Each piece now leaves every position it has held, and the screen shows eight arcs, the shape gravity gives each path. The result still clears everything. Restore the line. Then delete `inc (ix+3)`, turning gravity off. The pieces fly in straight lines. The centre piece rises 12 pixels an update and enters the HUD after 12 updates. Two updates later its Y would go below 0: the byte wraps to 254, the floor test catches that, and the piece drops to the floor and climbs again. Finally, set `FLASH_BORDER` to 7 for a white flash.

Space launches; O/P steer; hold Space for 2X. One hit ends the run: the border flashes, the ship breaks apart for a second, then the result appears. R and Q do nothing until then; at the result R retries and Q returns to the title.

Repeat: launch and leave the ship still. The first meteor hits it about 2.2 seconds after launch, at the centre. Hold O and Space from launch to be hit at the left edge, where pieces moving left stop at X 8; P and Space give the right edge.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
