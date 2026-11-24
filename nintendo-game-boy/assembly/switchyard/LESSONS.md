# Switchyard: three Game Boy assembly experiments

A parcel is waiting at the fork. Send it down the track that reaches the marked destination. In these three steps you will draw the fork, give the player control over it, then make their choice count.

Build from this directory with `make` using the tools in [the build and proof notes](README.md). Select the original monochrome Game Boy (DMG) in the emulator. Load each generated `.gb` as a cartridge, then start or reset the emulated machine. **A**, **B** and **Start** below mean Game Boy button names, not physical keyboard keys. Use your emulator's mappings. These steps cover the named DMG configuration in the build notes, not every Game Boy or browser.

## 1. Put a fork on the screen

Open `build/01-junction.gb`. Find the right-pointing marker on the upper track. No button input is needed yet. The screen is a grid of small pictures called tiles. A map entry chooses one picture for one square; it does not draw the whole track or decide where a parcel goes. Find `ld [UpperGate],a` in [`01-junction.asm`](01-junction.asm). Column 9, row 8 is `$9800 + 8 × 32 + 9 = $9909`: each map row is 32 entries wide even though only 20 fit across the screen.

**Predict and change:** In [`01-junction.asm`](01-junction.asm), change `ROUTE_UP_TILE EQU 2` to `ROUTE_UP_TILE EQU 4`. Rebuild with `make build/01-junction.gb` and load the rebuilt cartridge. Which square will change? The upper marker becomes a diamond, using the parcel tile already defined by the sample. The track and destination stay put. Restore the original value and rebuild before moving on.

## 2. Make A throw the points once

Open `build/02-switch.gb`. The arrow starts on the lower track. Pressing **A** moves it to the upper track. Before pressing, predict what will happen if you keep **A** down instead of letting go.

**Try it:** Hold **A** across several frames, release it, then press it again. The first press changes the selection; holding and releasing do not change it; the second press changes it back. In [`02-switch.asm`](02-switch.asm), find `PreviousA`. The loop saves the current sample even on release. That lets it tell a fresh press (down now, up before) from a held button (down in both samples).

**Change one line:** After saving `PreviousA`, the loop uses `ld a,b` to check for a fresh press. Predict what happens if you change it to `ld a,c` to check whether A is down now instead. Rebuild with `make build/02-switch.gb` and try a long hold. The route now flips every frame while A is down instead of just once. Restore the original line before moving on.

## 3. Send a parcel and read the result

Open `build/03-delivery.gb`. The marked destination is on the upper branch and the starting selection is lower. **A** selects the other branch while the parcel is waiting. **Start** sends it to that depot in one move. A tick means delivered, a cross means missed. **B** after either result returns you to the starting state.

**Predict and compare:** From reset, predict which end the parcel reaches if you press **Start** without changing the switch. Run that attempt and read the missed result. Press **B**, then change just one thing: press **A** once before **Start**. Check that the parcel now appears at the upper depot with the delivered tick. After a result, check that **B** returns the parcel and switch to their starting positions so you can try again.

Find `.dispatch` in [`03-delivery.asm`](03-delivery.asm). The loop handles A before it checks Start, then compares the selected route with `UPPER_ROUTE` to choose `DELIVERED` or `MISSED`. The tile art shows the decision; it does not make it.

**Change the starting choice:** In `reset_attempt`, replace `ld a,LOWER_ROUTE` with `ld a,UPPER_ROUTE`. Before rebuilding with `make build/03-delivery.gb`, predict what Start alone now does. Test from reset and again after B. Did you change the delivery rule or only the route you begin with?
