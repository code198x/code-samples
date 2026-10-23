# Four map operations on a stock 1 KiB ZX81

Merge `room.bas`, `demo.bas`, `routines.bas` and `extras.bas` into one program, then RUN on the original ROM with 1024 bytes of RAM. At the command prompt, use CLS between entered lines if the automatic listing fills the scarce workspace; the stock verifier does this for its fresh fault/repair programs. The listing shares RAM with the program. The caller prints **3, 2, 2**: read (0,1), write tile 2 there, and read it back. STOP reports 9/95. Keep these listings separate from the readable parent version; their line numbers and contracts differ.

The complete tokenised program is **683 bytes**: room 46, caller 117, checked read/write 304, property/world routines 216. The stopped public caller has an observed 101-byte stack-to-workspace gap. A different caller allocates other variables and changes that gap; neither value is a guaranteed free-memory budget.

## A smaller representation and contract

M$ stores a 7×5 room as 35 digit characters. Its variable record is 38 bytes including the header, compared with 175 bytes for the numeric map's element payload alone. Every stored character must represent ID 0–3. This room repeats 0,1,2,3; it deliberately does not reproduce the readable room's irregular final row or trailing guard.

| Call | Supply | Result |
| --- | --- | --- |
| GOSUB 100 | C=column, R=row | T=ID; T=-1 on invalid coordinate; D=one-based string subscript on success |
| GOSUB 200 | C,R,V=new ID | T=V on success; T=-1 on failure; rejected calls leave M$ unchanged |
| GOSUB 300 | T=ID | F=property; F=-1 on invalid ID |
| GOSUB 400 | X,Y=non-negative world position | C=INT(X/8), R=INT(Y/8), then T from the checked reader; negative input returns T=-1 before conversion |

There is **no E flag**. Test T>=0 for a read/write/world result or F>=0 for a property result. Cell coordinates and IDs must be whole numbers; the guards reject fractions. World positions may contain fractions. Call 400 only with finite values in a range where division is meaningful to your game (the exercised edge cases are near this room).

The caller owns M$ and must initialise exactly 35 valid characters before calling. C/R/V/X/Y are arguments; T/D/F are results and scratch. Reads change T and, on success, D. Writes call the reader and change M$ only after success. Properties change F; world queries change T and, after non-negative checks, C/R/D. An early return leaves other scratch alone. These globals make calls non-reentrant; save results you need across calls.

Width 7, height 5, cell size 8 and four properties are fixed in the code. CODE subtracts 28 to decode a digit; CHR$ adds 28 when writing. This saves numeric storage but adds conversion work. It is not a timing benchmark or a claim that strings are always faster. The readable version keeps descriptors, a property array, separate success status and more generous validation contracts. Choose it when those freedoms matter more than fitting the stock machine.

## Change it safely

Replace digits in the room string without changing its 35-character length or using IDs outside 0–3. Changing width requires both bounds and the multiplier in line 150 to change; height, string length and world extent must agree. Changing cell size requires both divisors in 430/440 to change. Use the readable version rather than gradually inventing a second descriptor system here.

Replace line 340 with `customise.bas` to change the goal property from 4 to 5. No room IDs change. The fixed property calculation is compact but less flexible than a P array.

`verify-caller.bas` replaces lines 50–95 of the public demonstration and initialises F at line 20. It asks for C, R, V and target line (100/200/300/400), copies the first two inputs to X/Y and V to T, calls the selected routine, then prints T/F. CLS keeps the diagnostic display bounded. Interpret only the relevant output. This harness is for bounded testing, not additional code to keep alongside the public caller.

The `mistakes/` files are deliberately faulty **single-line replacements**. With the wrong stride, reading (0,2) returns 0 instead of 2: restore `150 LET D=R*7+C+1`. Removing the return guard at 230 allows an out-of-room write to reuse an earlier D and damage a different cell. Restore `230 IF T<0 THEN RETURN`. Enter the replacement before running a fresh program and first read (0,0) before reproducing that write fault, so the stale subscript is known. An INPUT prompt is not the command editor.

The native records in `../verification/memory/` retain stock execution, heap and display bytes, source/ROM/tool identities, customisation and fault/repair observations. Small programs still need space for editing, INPUT, calculator temporaries and return stacks. Growing the room or adding output requires another measurement.


## Reproduce the measurements

From the repository root, with the verified Emu198x 0.44.1 native executables in one directory and the original ROM configured locally:

```
python3 scripts/verify-zx-map-memory.py --native /path/to/native-emulators --system sinclair-zx81 --ram 4096
python3 scripts/verify-zx-map-memory.py --native /path/to/native-emulators --system sinclair-zx81 --ram 2048
python3 scripts/verify-zx-compact-map.py --native /path/to/native-emulators --system sinclair-zx81
python3 scripts/check-zx-map-memory.py --refresh-manifests
python3 scripts/check-zx-map-memory.py
python3 -m unittest discover -s scripts -p test_zx_map_memory.py -v
```

The compact observer fixes RAM at 1024 bytes, boots the original ROM and enters each line through its keyboard. It neither injects a tokenised program nor installs extra RAM. Qualification is for the recorded aarch64-apple-darwin executable and ROM hashes; other hosts need their own fresh qualification. CI decodes retained observations; it does not redistribute or run proprietary firmware.


## Account for the whole stock machine at STOP

These figures describe the public caller's stopped checkpoint, not its maximum runtime usage.

| Allocation or separation | Bytes |
| --- | ---: |
| Tokenised program | 683 |
| System area | 125 |
| Variables, including string header and terminator | 69 |
| Collapsed display file | 32 |
| E_LINE to STKEND | 2 |
| RAM top minus CPU SP | 12 |
| CPU SP minus STKEND (unallocated separation) | 101 |
| **Total** | **1,024** |

The accounting agrees with the actual ROM pointers, variable/display extents and CPU SP. A larger caller changes the allocations; the last row of separation is not a guaranteed reserve for game content.

After fresh native runs, visually review the captures before `--refresh-manifests`. The option checks both machines' complete observations before updating any file bindings; the ordinary checker and CI never refresh them.

During verified fresh entry, CLS reclaimed up to 407 bytes of automatic-listing display storage without moving D_FILE or altering the stored program. This is entry-time workspace, separate from the 32-byte display at the stopped public caller.
