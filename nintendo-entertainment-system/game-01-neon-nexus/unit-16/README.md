# Unit 16: Final Polish

Complete release version with all features.

## What This Unit Covers

- Code organisation
- All features integrated
- Production-ready ROM
- Complete gameplay loop

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator.

### Controls

| Button | Action |
|--------|--------|
| D-Pad | Move player |
| START | Pause / Start game |
| A/B | Start from title |

## Complete Feature List

- Fixed-screen arena gameplay
- Multiple enemy types with distinct patterns
- Collectible items with scoring
- Lives system with respawn
- Progressive difficulty
- High score tracking
- Sound effects via APU
- Pause functionality
- Title and game over screens
- Visual polish effects

## Code Organisation

1. **Header** - iNES format specification
2. **Constants** - Hardware registers, game values
3. **Variables** - Zero page and RAM allocation
4. **Reset** - Startup and initialisation
5. **NMI** - VBlank handler and rendering
6. **Main loop** - State machine dispatch
7. **Input** - Controller reading
8. **Game logic** - Player, enemies, items
9. **Collision** - Hit detection
10. **Audio** - APU sound effects
11. **Data** - Graphics, tables, nametables

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
