# Tile-map queries: mattel-aquarius

Use `demo.bas` as a complete stock-BASIC program, or copy the numbered subroutines from `routines.bas` into your own program. Keep their line numbers free, or update every GOSUB when relocating them. Run the program to see a six-row map, inspect a hazard's tile/property value, change it into a goal and draw the changed map.

## Include and initialise

The start of `demo.bas` defines W=8 columns, H=6 rows, S=8 world units per tile and L=3 as the highest tile ID. Allocate M(W*H-1) and P(L). Fill every map and property entry explicitly. W, H and S are positive integers; L is a non-negative integer; allocated arrays must match them. Arrays use zero-based coordinates. Tile IDs must be integers from zero through L. The sample uses 0 floor, 1 wall, 2 hazard and 3 goal; the property table contains 0, 1, 2 and 4 respectively.

Numeric arrays consume this BASIC's numeric-element storage, not one byte per tile. This trades memory for readable, editable code. There is no frame-rate claim. Store tile bytes in memory/ROM, pack small IDs, use row pointers or decode rooms when memory or query speed matters; those require a separate implementation.

## Call the routines

| Entry | Inputs | Outputs |
| --- | --- | --- |
| GOSUB 1000 | C column, R row | E=1 and T tile ID on success; E=0 and T=-1 outside the map or for fractional coordinates. D is scratch. |
| GOSUB 1100 | C, R, V new tile ID | E=1 and T=V after a valid write. Invalid coordinates/ID leave the whole map unchanged and set E=0; do not use T after failure. |
| GOSUB 1200 | T tile ID | E=1 and F=P(T) on success; E=0 and F=-1 for invalid IDs. Does not read the map. |
| GOSUB 1300 | X, Y non-negative world coordinates, S tile size | C=floor(X/S), R=floor(Y/S), then the same lookup as 1000. Negative X/Y or non-positive S give E=0 and C=R=T=-1. Non-negative positions beyond the map retain calculated C/R, with E=0 and T=-1. |
| GOSUB 1400 | Q/U source column/row, A/B positive region width/height | Prints IDs as character codes 48+T, starting at the current text cursor. E=1 on success. An invalid or partly outside region gives E=0 and prints nothing. Consumes C, R, T, D, J, K. |

Check E immediately after each call; another call replaces it. A failed query is not a solid tile or an empty tile: choose that policy in your game. No routine accepts a negative subscript and relies on BASIC to wrap it.

Region drawing is a text adapter for the sample's IDs 0–3. It does not move the cursor to a screen coordinate, draw custom glyphs, manage colour or wrap a camera. Replace its PRINT mapping when adopting another tile set. Do not put player/enemy positions into the background map just to draw them: keep those objects separately if the underlying tile must survive movement.

## Ownership and combinations

The routines use global BASIC variables and are not re-entrant. Reserve M/P arrays (MM/PP on Atom), W/H/S/L, inputs and outputs above, and D/J/K scratch. The caller owns and initialises map/property data and the current text cursor. Region drawing uses J/K as loop variables; do not call it inside a caller loop that needs J/K preserved. Get/set/property/conversion do not allocate arrays or clear the display.

To test a position: set X and Y, call 1300, check E, then call 1200 and check E again. The property value can classify a wall, hazard or goal independently of its artwork. Writing a map cell changes logical data; redraw that cell or region through your chosen display adapter. A scrolling engine may cache only a visible window while queries still address the full logical level.

## Dialect and coordinates

This version uses numeric arrays, INT for floor division and CHR$ for the sample text mapping. Fractional tile coordinates/IDs are rejected; positive fractional world coordinates are allowed and convert to a tile. Use world coordinates before camera subtraction: a camera-relative screen coordinate can refer to the wrong logical tile. The sample uses square tiles; use separate horizontal/vertical sizes if your logical cells differ.

## Verification

The retained record distinguishes a built/loaded caller from executed query and drawing checks. It names the interpreter firmware, emulator binary, source hashes, test expectations and deliberate negative controls. See `docs/tilemaps/` for coverage of all registry machines. A text map is not evidence for a native graphical renderer or a whole game's frame budget.

The compact demo runs unexpanded. The larger edge-case harness uses a 16 KB RAM expansion; its first unexpanded query run reported `?OM Error in 1050`. This is a harness/workspace requirement, not a claim that the expanded map representation costs one byte per cell.
