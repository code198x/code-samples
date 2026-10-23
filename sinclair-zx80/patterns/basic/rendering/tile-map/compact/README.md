# The same checked room on a stock 1 KiB ZX80

Keep the readable routines. Replace only the original `room.bas` with this folder's `room.bas`; merge it with **the parent `routines.bas` and parent `demo.bas`**, then RUN. The original ROM executes the same five-result demonstration on 1024 bytes of RAM.

The generated room is identical: seven columns, five rows, the original three final-row overrides, the trailing guard and four properties. `J-4*(J/4)` supplies the repeating 0,1,2,3 IDs because this ROM uses integer division. J runs 0–34; lines 2090–2110 supply the irregular final cells. M(35)=9 remains outside the playable room.

| Tokenised component | Readable | Compact room |
| --- | ---: | ---: |
| Query routines | 331 | 331 |
| Room initialiser | 475 | 166 |
| Public caller | 175 | 175 |
| Total program | 981 | 672 |

The saving is **309 program bytes**. The FOR control variable uses another 7 bytes at the stopped caller: variables occupy 131 bytes rather than 124. The example's display occupies 67 bytes and the system area 40 bytes. The observed stack-to-display-end gap at STOP is 110 bytes. That is a checkpoint, not a guaranteed worst-case reserve.

## What stays reusable

Every parent routine contract remains intact: GOSUB 1000 reads, 1100 writes, 1200 finds properties and 1300 converts world coordinates. Keep E as the success flag. W/H/L/S, zero-based arrays, range limits and ownership remain as documented in the parent README. You still have a data-driven P table and configurable dimensions and cell size. Calls use no additional compact-only API.

The initialiser reserves J as well as the parent variables. A patterned room is cheaper to describe but takes interpreted loop work to generate. Arbitrary rooms with many exceptions will lose that program-size advantage. This is a storage comparison, not a measured speed improvement.

To customise the goal, use the parent `customise.bas` replacement at line 2450. To change the room size, change dimensions, allocation, loop bounds, overrides and guard position together. The program fitting in 1 KiB does not mean an arbitrary game or full-screen diagnostic will also fit.

## Check calls and recognise faults

`verify-caller.bas` replaces the public caller for bounded verification; merge it with this room and the parent routines. It repeatedly asks for C, R, V and a subroutine line number (1000/1100/1200/1300), then prints T and F. For world queries the first two inputs become X and Y; for properties the third input becomes T. Only the relevant returned value and E should be interpreted. CLS bounds the verification display. For another fault experiment, reset and enter a fresh program with the chosen replacement before RUN; an INPUT prompt is not the command editor. After a ZX80 report, press a key to return to command mode.

The two files under `mistakes/` are **one-line replacements**, deliberately wrong. Wrong stride at 1070 reads (0,2) as 0 rather than 2; restore `1070 LET D=R*W+C`. Replacing the write return guard at 1150 with the deliberately useless `LET E=E` lets a rejected (7,0) write change the first cell. Restore `1150 IF E=0 THEN RETURN`. Start from a fresh RUN between fault tests so earlier writes do not hide the symptom.

Native records under `../verification/memory/` bind the listings, ROM and emulator. The original 16 KiB exhaustive records remain separate and unchanged. The compact observer uses a real BASIC INPUT/GOSUB caller; immediate commands do not substitute for a program's return context.


## Reproduce the measurements

From the repository root, with the verified Emu198x 0.44.1 native executables in one directory and the original ROM configured locally:

```
python3 scripts/verify-zx-map-memory.py --native /path/to/native-emulators --system sinclair-zx80 --ram 2048
python3 scripts/verify-zx-map-memory.py --native /path/to/native-emulators --system sinclair-zx80 --ram 1024
python3 scripts/verify-zx-compact-map.py --native /path/to/native-emulators --system sinclair-zx80
python3 scripts/check-zx-map-memory.py --refresh-manifests
python3 scripts/check-zx-map-memory.py
python3 -m unittest discover -s scripts -p test_zx_map_memory.py -v
```

The compact observer fixes RAM at 1024 bytes, boots the original ROM and enters each line through its keyboard. It neither injects a tokenised program nor installs extra RAM. Qualification is for the recorded aarch64-apple-darwin executable and ROM hashes; other hosts need their own fresh qualification. CI decodes retained observations; it does not redistribute or run proprietary firmware.


## Account for the whole stock machine at STOP

These figures describe the public caller's stopped checkpoint, not its maximum runtime usage.

| Allocation or separation | Bytes |
| --- | ---: |
| Tokenised program | 672 |
| System area | 40 |
| Variables, including array headers and terminator | 131 |
| Display file | 67 |
| RAM top minus CPU SP | 4 |
| CPU SP minus display end (unallocated separation) | 110 |
| **Total** | **1,024** |

The accounting agrees with the actual ROM pointers, variable/display extents and CPU SP. A larger caller changes the allocations; the last row of separation is not a guaranteed reserve for game content.

After fresh native runs, visually review the captures before `--refresh-manifests`. The option checks both machines' complete observations before updating any file bindings; the ordinary checker and CI never refresh them.
