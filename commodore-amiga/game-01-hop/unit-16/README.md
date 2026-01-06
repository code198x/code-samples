# Unit 16: Final Game

Complete polished version with all features.

## What This Unit Covers

- Code organisation
- All features integrated
- Production-ready game
- Complete gameplay loop

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator.

### Controls

| Input | Action |
|-------|--------|
| Joystick | Move frog |
| Fire | Start / continue |

## Complete Feature List

- Classic Frogger gameplay
- Road lanes with moving traffic
- River lanes with floating logs
- Platform riding mechanics
- Collision detection
- Lives and scoring system
- Home zone goals
- Level progression
- Time limit with bonus
- High score table
- Sound effects
- Title and game over screens

## Code Organisation

1. **Constants** - Hardware registers, game parameters
2. **Copper list** - Display configuration
3. **Main loop** - State machine dispatch
4. **Input** - Joystick reading
5. **Movement** - Frog and object updates
6. **Collision** - Hit detection routines
7. **Drawing** - Blitter and sprite rendering
8. **Audio** - Paula sound playback
9. **Data** - Graphics, samples, tables

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
