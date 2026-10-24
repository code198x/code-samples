# Checked map queries in AMOS

Read a cell, change it and look up its properties without tying your map data to the screen. `caller.amos` supplies a small 7×5 map; the maintained helper labels live in `routines.amos`. Run `make`, import `build/demo.asc` as ASCII into AMOS Professional 2.00, syntax-check with F2 and run with F1. It prints the queried tile/flags and then the changed tile; Q returns to the editor. These are original ASCII modules, not tokenised AMOS save files.

## Include, allocate and call

Paste/import the caller followed by the helper once. Keep the caller’s End before the labels so execution cannot fall through into a subroutine. Merge the helper labels into an existing project and rename the PL_TM prefix if it conflicts with its variables. Every shared value here is a normal AMOS integer; string, floating-point and assembly-pointer contracts are not transplanted into this route.

The caller allocates PL_TM_MAP(last-index) and PL_TM_PROPS(last-index). AMOS DIM’s final value is an inclusive upper index: DIM PL_TM_MAP(34) provides 35 elements, indexed 0–34. Set PL_TM_W/H to 1–255 cells, PL_TM_CAP to the actual allocated element count, PL_TM_MAX to the highest tile ID (0–255), and PL_TM_PC to the property element count (at least MAX+1). Map order is rows of W cells: row*W+column. Initialise all used map cells and properties before calling. Capacity values are caller promises; these routines cannot discover or repair a falsely declared DIM allocation.

- **PL_TM_GET:** set X/Y; Gosub the label; check VALID immediately. It returns TILE and clears PROP. Failure returns VALID=0, TILE=0, PROP=0. Zero tile alone is not success. A stored tile outside 0–MAX is rejected too.
- **PL_TM_SET:** set X/Y/TILE; call; check VALID. Invalid dimensions, declared capacity, coordinates or tile IDs cannot change the map. TILE remains the supplied value; PROP is cleared. It does not draw.
- **PL_TM_PROPERTY:** set TILE; call; check VALID before PROP. It checks the highest ID and property capacity independently of map dimensions. Failure returns PROP=0 and leaves TILE unchanged. Property bits are your game’s meaning, not renderer commands.
- **PL_TM_PIXEL8:** set WX/WY to whole world coordinates 0–65535. Call, check VALID, then use X/Y/TILE. It divides by eight with Int and uses the checked read. Negative/out-of-range world inputs return zero outputs; a positive converted cell outside the map is rejected. WX/WY survive. Other cell sizes need another conversion; a negative world needs an explicit origin policy.

The routines own their PL_TM state and index scratch, and use the normal Gosub stack. They do not allocate arrays, reserve banks, wait, draw, read input or touch a global clock. Do not recursively share one context or let another caller change its inputs before consuming the result. The small caller’s output and the qualification bank are not helper requirements.

## Make it your own

The qualification map uses four tile IDs and a four-element property table. Bit 0 means solid and bit 1 means exit only by this caller’s convention. `custom` changes the exit tile’s property from 2 to 1; every property query must then return that new value, and the native display shows Exit: 1 instead of 2. Allocation, helper code and map dimensions remain unchanged. A game decides whether a solid exit makes sense; the lookup merely returns the data.

Map data can be larger than a screen, and a renderer can draw only the visible region. This library layer deliberately does no region drawing. More IDs need a larger property allocation and matching MAX/PC values. Wider maps, a different world origin, row-offset tables, packed storage or compressed rooms need their own contract/qualification. The 255-cell dimensions are a chosen small-map interface, not a limit of Amiga hardware.

## Common error: multiply by height

The labelled wrong build replaces row*W+column with row*H+column. It still stays within this bounded allocation and completes all observations, so a clean exit cannot detect the error. On the non-square 7×5 map, reading column 0, row 1 returns tile 1 instead of 3. The same fault can alter a different cell during a valid write. Restore W in the stride expression. `repaired` imports exactly the original working source and passes the full oracle again.

The captured native trace records every operation and the full map after it; result values are not injected by the observer. Every invalid write must leave all 35 map elements and the following guard unchanged. A square map would hide this stride mistake, which is why the independent caller is non-square.

## Costs and execution evidence

The small example allocates 35 map integers and four property integers, plus named scalar state and the runtime’s array/variable metadata. This does not claim a total compiled or interpreter RAM footprint. Row-major lookup uses an interpreted multiplication and indexed access. A row-offset table would spend more storage to avoid repeated multiplication; no speedup or cycle count is measured here.

The qualification caller adds one guard element and a 3,074-byte work bank: 64 records of 48 bytes plus a final marker. That bank is instrumentation, not a game requirement. Its 64 cases cover every cell, negative/outside reads, invalid writes/IDs, a successful write/read, properties, eight-unit conversion and invalid dimensions/capacity. The map after each operation is checked against an independent row-major host oracle. The small reader-facing caller also runs independently and displays Tile: 1, Flags: 1 and Changed tile: 2. Working, custom, wrong, repaired and boundary runs execute separately in the original runtime. The boundary run repeats the supplied-value caller rather than claiming another algorithm.

Emu198x 0.44.2, A1200 PAL, 2 MiB chip/no fast RAM, recorded Kickstart and AMOS Professional 2.00 media, and Build198x-ADF 0.2.13 are the named configuration. A fresh original-runtime cold boot and blank editor precede ASCII import and F2/F1. Import settles for bounded 300-frame windows; an earlier 100-frame boundary import reached the editor without starting and was rejected. Source-fixture, source/tool/firmware/runtime identities, native work-bank bytes, complete markers and numeric capture recognition are retained under verification. Private runtime/media/snapshots are not distributed. This is not host-interpreter or original-hardware timing proof.

Run `python3 scripts/check-amos-map-queries.py` and `python3 -m unittest discover -s scripts -p test_amos_map_queries.py -v` from the samples root. `verify-amos-map-queries.py` accepts explicit original runtime/firmware, emulator, disk-builder and fresh private-directory paths for replay. Corruptions must fail before publication. After capture, Q exits the diagnostic and releases its bank; the retained quit image is an observation, not an automatic proof of all editor cleanup behaviour.

Coordinates, array indexing, integer division and flag sets connect naturally to Maths for Games. This routine returns data; collision, movement and drawing callers decide what it means.
