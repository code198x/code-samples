# Unit 2: Notes in Motion

Note spawning and movement system with frame-synchronised timing.

## What This Unit Covers

- Note array management (4 simultaneous notes)
- Zero-page indirect addressing for screen writes
- Raster synchronisation for consistent timing
- Timer-based spawning and movement
- Note lifecycle (spawn, move, despawn)

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware. Notes spawn automatically and scroll left across track 2. Press **X** to play sounds.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Note arrays | Parallel arrays track X position per note |
| $FF marker | NOTE_INACTIVE value marks empty slots |
| Raster sync | Wait for $D012 to reach specific line |
| Frame timers | Count-down timers control spawn/move rate |

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
