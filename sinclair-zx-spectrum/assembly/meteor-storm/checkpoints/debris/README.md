# Break the ship apart

In the previous program a hit played the impact sound and then `result` cleared the screen at once, so the player never saw what hit them. Now contact starts a short destroyed phase. The storm stops where it is, still drawn, and the ship breaks into five pieces that fly apart for one second before the result appears.

`destroyed` sets `phase` to 2, erases the ship and copies five debris records from `debris_start`. Each record is four bytes: X, Y, dX and dY. They use the fixed offsets of unit 12's object records, and unit 13's pool walk visits them: IX points at the current record and B counts the pieces. Every piece starts at the ship's own X, so each obeys the same 8..224 contract as the ship. The debris artwork sits in the middle of its 24-pixel sprite, over the ship's centre columns, and each piece starts on a different row of the ship.

Then `destroyed` runs its own loop of `DEBRIS_UPDATES` (25) updates at the main loop's rate. It waits with `wait_frame`, skips odd frames as the main loop does, and each update does the three familiar steps: `draw_debris` erases every piece, `move_debris` adds dX and dY, and `draw_debris` draws them again. `draw_debris` uses `draw_sprite`, and XOR makes one routine do both jobs. Pieces pass over frozen meteors without damaging them. A piece that would leave X 8..224 keeps its X, the bounds idea from drift, and slides straight up the edge instead. Every dY is negative, so pieces only rise from the ship's rows: the fastest reaches y=86 after 25 updates, well clear of the HUD. When the count reaches zero the program falls into `lost` and the result as before; `result` clears the screen, so no piece survives it.

Two details make the collision visible. The meteor that hit now keeps its slot and its image (`meteor_contact` jumps to `advance_meteors_skip` instead of removing it), so it sits where the ship was. The run is over, so the extra active slot changes nothing: `new_game` clears it with the rest of the run block. And the impact sound now goes through `start_sound`, so the frame waits of the destroyed phase play it while the pieces move. Blocking first would hold the pieces still on the ship for about 193 ms (ten frames) before they flew, and the sound would stop before anything moved.

| Part | Measured in Emu198x |
|---|---|
| Destroyed phase | 49 frames (25 updates, about one second) from contact to the result |
| Impact notes | 882, 668 and 525 Hz (computed 886, 667 and 524) |
| Impact length | 211 ms from first to last edge, against 193 ms of tone |
| Gaps in the impact | five silences of about 3.6 ms, one per update, 40 ms apart |

The gaps are the same 25 Hz flutter the previous program described for long sounds: each update erases, moves and redraws the pieces while the speaker waits. Against a falling crash it reads as crackle, not a fault. Arrival is unchanged: it still blocks through `play_sound` and cuts straight to the result, so destruction and arrival stay distinct.

`debris_time` and `debris` sit in the run block, so a retry starts with no debris. The destroyed phase reads no keys: R and Q do nothing until the result, and a key still held when the result appears waits for release first, as before. Flight, collision, scoring and the course are unchanged. The accepted keyboard routes finish with the same frames, times and scores, and a run that ends in contact reaches its result about a second later.

Predict, then check: delete the first `call draw_debris` after `jr nz,destroyed_wait`, so pieces are drawn but never erased. Each piece now leaves a streak of every position it has held, a fan of lines spreading from the ship, and XOR cuts holes where a streak crosses the meteor. The result still clears everything. Restore the line. Then change `DEBRIS_UPDATES` to 50: the pieces fly for two seconds and the fastest rises to y=11, into the HUD's second line. XOR restores the HUD as it passes.

Space launches; O/P steer; hold Space for 2X. One hit ends the run: the ship breaks apart for a second, then the result appears. R and Q do nothing until then; at the result R retries and Q returns to the title.

Repeat: launch and leave the ship still. The first meteor hits it about 2.2 seconds after launch, at the centre. Hold O and Space from launch to be hit at the left edge, where the pieces moving left stop at X 8 and rise; P and Space give the right edge.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).
