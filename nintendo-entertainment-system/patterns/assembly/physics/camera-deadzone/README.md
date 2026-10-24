# Camera Dead Zones on NES

A camera need not move every time the player takes a step. Keep a quiet area on screen, and scroll only when the player pushes beyond it. The camera should also stop at the edge of the world rather than revealing an empty border.

## Bind, initialise and call

Allocate the contiguous private bytes CAMERA, PLAYER, LEFT_EDGE, RIGHT_EDGE, SCROLL_LIMIT, SHIFTED, VALID in that order. Include component.inc once, call camera_deadzone_init, then set the starting inputs/state. Init clears every named byte, including inputs. Call camera_deadzone_step for each intended service. Use one owner; independent instances need distinct state and scoped/renamed labels. No helper owns a clock, input reader, display, allocation or interrupt controller.

CAMERA and PLAYER are unsigned world coordinates. LEFT_EDGE/RIGHT_EDGE are permitted screen-relative player thresholds, with LEFT_EDGE ≤ RIGHT_EDGE. SCROLL_LIMIT is the largest camera coordinate; the current CAMERA must already be within 0–SCROLL_LIMIT. Invalid bounds leave CAMERA unchanged and clear SHIFTED/VALID. Otherwise step sets VALID, moves just enough to put the player on the crossed threshold, clamps to 0–SCROLL_LIMIT and sets SHIFTED exactly when CAMERA changes. Player and bounds survive.

Initialise, establish valid world/view limits and update PLAYER in world coordinates. Service after movement, then pass CAMERA to the renderer’s coordinate conversion or scrolling backend. The normal 40–80 dead zone moves the camera from zero to ten for player 90, then to twenty for player 100.

Seven bytes. CAMERA persists; PLAYER and the three bounds are inputs; SHIFTED and VALID are replaced flags. PLAYER − CAMERA is computed without byte-wrap mistakes, including when the player lies to the left of the camera.

A/X/flags may change; Y and decimal mode survive. Clear decimal mode before binary arithmetic; the caller uses CLD. A direct call needs two return-address stack bytes.

## Customisation and errors

The custom caller sets both thresholds to 60. The dead zone has zero width, so the camera tracks the player at that screen position until a world edge prevents it. The two calls finish at camera 40 instead of 20.

The wrong client subtracts CAMERA from PLAYER before calling the world-coordinate API. The second request supplies screen position 90 in place of world position 100, leaving the camera at ten. Keep world and screen coordinates separate and subtract the camera only in the rendering path.

The byte world is a bounded example, not a universal camera range. Wider maps need wider coordinates; smoothing adds fractional state and a time-step policy. Hardware coarse/fine scrolling, exposed map columns and parallax remain separate display-specific work. If bounds shrink, first move CAMERA into the new valid interval.

## Cost and evidence

Measured extent: 90 code bytes, 0 immutable data bytes and 7 private state bytes, excluding alignment, return-address/temporary stack, the case table and presentation machinery. A relative-position comparison and one clamped correction, with no map copy or display transfer. C64/Amiga hardware capabilities are not reduced to this logical byte coordinate; their renderers may need wider and differently split scroll values.

Run make with ASM198X; the Amiga build also accepts BUILD198X. Four variants are maintained: demo, custom, deliberately wrong and exact repair. Observed rows: demo 14 64 28 50 9B 01 01 00; custom 28 64 3C 3C 9B 01 01 00; wrong 0A 5A 28 50 9B 00 01 00. These are the first eight state bytes, padded/truncated for display. The packet records all bytes after every call.

Native configuration: NTSC mapper-0 NES cartridge, CHR-ROM diagnostic font, NMI/DMC disabled; Asm198x 0.0.72 and Emu198x 0.44.2. Each run covers 64 boundary/varied/error table cases plus a separate sequential client and dirty-state init. Checked source/tool/firmware identities, preserved-register sentinels, actual helper/data extents, immutable loaded bytes, independent integer packet, screenshot pixels and exact repair are retained in verification/. Restricted firmware and snapshots are not distributed. This is configuration-specific qualification, not exhaustive input coverage or original-hardware timing.

Refresh with scripts/verify-playtools.py --topic camera-deadzone --help; check-playtools.py and test_playtools.py validate every explicit target and reject changed evidence. The shared test models are verification inputs, not runtime dependencies. The client’s checked_step wrapper calls the public camera_deadzone_step entry; emit_state is only a diagnostic observer. In a game, call the public entry directly and consume its documented outputs.

The standalone cartridge owns its background/font and test RAM layout. Its bounded packet, preview and completion marker fit below the end of the NES’s 2 KiB internal RAM. The helper itself owns no PPU, DMA or audio registers.
