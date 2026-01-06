# Unit 6: The River

River section with log graphics.

## What This Unit Covers

- Multiple lane types (road vs river)
- Log sprite/blitter graphics
- River colour palette
- Safe zone detection

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator. River lanes appear above the road with floating logs.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Lane types | Road (cars) vs river (logs) |
| Log graphics | Horizontal platforms to ride |
| Water danger | River without log is fatal |
| Zone layout | Safe, road, river, home |

## Screen Layout

| Rows | Type | Description |
|------|------|-------------|
| 0-15 | HUD | Score and lives |
| 16-47 | Home | Goal slots |
| 48-111 | River | Logs and water |
| 112-175 | Road | Cars and trucks |
| 176-207 | Safe | Starting area |

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
