# Checked map queries — ZX80 BASIC

Run the unchanged public caller with the original ROM and **2 KiB RAM** or more. This configuration has now been executed; the earlier exhaustive diagnostics remain qualified at 16 KiB. A separate [stock 1 KiB option](compact/) is available below. No assembly or dependency is required.

## Include and call

Enter/merge `routines.bas` (1000–1380), `room.bas` (2000–2460) and `demo.bas` (10–190) into one BASIC program, then RUN. The files are listing fragments, not separate programs to RUN in sequence. Use the ZX80's own keyword keyboard; GOSUB/GOTO in this text are the ROM's GO SUB/GO TO tokens where it displays spaces. Each line contains one statement. Reserve these line ranges or renumber **every** branch/call consistently.

The caller first calls 2000 once. It allocates M and P, selects W=7, H=5, maximum ID L=3 and world-cell size S=8, and fills the example data. Do not call the allocator again just to select another cell. In particular, re-DIM is not a portable way to switch rooms on the ZX80.

The demonstration prints TILE 3, FLAGS 4, CHANGED 3, WORLD 6,4 and TILE 2. It reads a cell, classifies it, changes another cell and converts a world position. STOP keeps the result available; the report 9/190 acknowledges STOP at line 190.

## Contracts

Logical columns and rows always start at zero. The BASIC array begins at **0**. The flat offset D=R*W+C is translated only at the final M(D+0) access; properties use P(T+0). M includes 35 cells plus a trailing diagnostic 9 outside the room. P has four property values: floor=0, wall=1, hazard=2, goal=4. Property values are game data, not renderer attributes.

| Call | Inputs | Outputs |
| --- | --- | --- |
| GOSUB 1000 | C, R; W, H, M | E=1, T=tile, D=flat offset; invalid E=0,T=-1,D=0 |
| GOSUB 1100 | C,R,V; L and read inputs | Valid writes M and returns E=1,T=V. Invalid ID leaves T unchanged; invalid coordinate returns E=0,T=-1. Never use T without E. |
| GOSUB 1200 | T; L,P | E=1,F=property; invalid E=0,F=-1 |
| GOSUB 1300 | X,Y,S; read inputs | Converts non-negative world coordinates to C,R, then reads the map. Invalid pre-conversion input gives E=0,T=C=R=-1. Out-of-map conversion preserves calculated C,R but returns E=0,T=-1. |

The original 4 KiB ROM uses signed integer arithmetic. Division truncates towards zero. The world routine rejects negatives first, so non-negative division gives the required floor. Keep every intermediate in -32768..32767; the room dimensions and their product must fit. There is no INT call or fractional-input promise.

The caller owns M/P, W/H/L/S and their lifetimes. Set positive integer dimensions, allocate the full W*H cells and L+1 properties, and initialise each tile to 0..L. Queries validate their arguments, not the truth of a descriptor or arbitrary writes by other code. The routines do not validate every stored tile or property value on every read.

Reserve scalar C,R,V,X,Y for arguments and E,T,D,F for results/scratch. A call only changes the variables it uses: read changes E,T,D; write also M; property changes E,F; world also C,R and invokes read. An early failure can leave other scratch unchanged. These globals make calls non-reentrant; save values needed by another call. M/P remain separate from single-letter scalar names. The demo and diagnostic reserve additional caller variables.

## Change a behaviour

With a fresh program, replace line 2450 using `customise.bas`, then RUN. Goal property changes 4→5, representing goal plus blocking (bits 4 and 1). The room's tile IDs stay unchanged. BASIC does not acquire bitwise operators from that convention; your game must interpret the values. Changing properties adds no elements or per-query work. More tile IDs require both L and P capacity/data to change; more cells require dimensions and M capacity/data to change together.

## Cost and display

The 35 numeric map elements, four properties and one guard require 80 bytes of numeric element payload (2 per element). Array headers, scalars, BASIC program text, display file, calculator/return stacks and interpreter workspace need additional RAM. This is not a free-memory measurement. A packed byte/string representation or assembly byte map can reduce data costs but changes indexing and update code.

These routines query data; PRINT is only the demonstration. The ZX80 stops generating its normal display while computing, so this is suitable for turn/command-driven work with pauses to display results, not a claim of smooth action graphics. No timing comparison with physical hardware is claimed. A multiplication occurs per successful cell lookup; row-offset tables trade additional storage/initialisation for a different query path.

## Deliberately broken variants

`mistakes/wrong-stride.bas` replaces the reusable routine file. It calculates D=R*(W-1)+C. Reading (0,1) completes with E=1,T=2 instead of 3. Restore the width W at line 1070. Test a non-square map and a later row; a row-zero test cannot catch the wrong stride.

`mistakes/write-without-valid.bas` omits line 1150. A write of 1 to (7,0) fails the read check, but D has been reset to zero and the unguarded assignment changes the first map element from 0 to 1. The returned E still says failure. Restore `IF E=0 THEN RETURN` before accessing M. Check both returned status and unchanged storage after a rejected write. These are full alternative routine listings for bounded diagnostics, not recommended code.

## Verify

From the repository root:

```
python3 scripts/verify-zx-basic-map.py --native /path/to/native-emulators --system sinclair-zx80
python3 scripts/check-zx-basic-map.py
python3 -m unittest discover -s scripts -p test_zx_basic_map.py -v
```

The runner boots each original ROM with 16 KiB, enters every line through the keyword keyboard and submits indexed calls through INPUT. It retains actual D_FILE bytes, complete map+guard prints, positive/customised/fault runs and source/tool/ROM identities. ROM files stay local. CI rechecks retained observations and falsification controls; it does not secretly rerun proprietary firmware.

Primary references: [ZX80 original manual, chapters 4/6/14 and appendix II](https://www.retroisle.com/sinclair/zx80/OriginalDocs/zx80manual.php), [ZX81 BASIC Programming, chapters 5/22/27 and appendix C](https://www.retroisle.com/sinclair/zx81/OriginalDocs/zx81manual.php). Source syntax, indexing and numeric behaviour are also exercised through the named stock ROM.

The automated entry uses conservative per-key gaps and a longer post-line pause for the expanded ZX81 display. It checks each stored ZX81 line number and waits for complete indexed output with a 6000-frame cap. These are transport bounds, not measurements of minimum keyboard latency or game performance.

The retained executable identity is the verified aarch64-apple-darwin release. A different host requires its own verified tool identity and fresh qualification; changing a recorded pass flag is not a requalification.


## Measured RAM, rather than the old test setting

The original readable listings are retained unchanged. Entering them through the ROM gives these tokenised storage costs (including line headers):

| Component | Bytes |
| --- | ---: |
| Reusable routines | 331 |
| Explicit room initialiser | 475 |
| Public caller | 175 |
| Total program | 981 |

The complete public caller runs on **2 KiB**. Entry of the unchanged listing into **1 KiB** is rejected with BASIC error 4 (out of memory). This is a comparison of exercised configurations, not an exact byte-by-byte minimum or a promise that a larger game will fit.

At the stopped caller, variables occupy 124 bytes and the display file 67 bytes; the 40-byte system area is separate. The stopped caller has an SP-to-display-end gap of **832 bytes** on 2 KiB. Its recorded sample is already at STOP, so it does not measure a range during execution.

These gaps are sampled separation between allocated data and the machine stack, not an instruction-level peak, a free-memory API or a safe game-content budget. Editing, INPUT, nested calls and additional output use workspace too. Read the retained `verification/memory/readable-*.json` pointer and CPU records alongside the separate original exhaustive test records.
