# Unit 16: Polish (Final Version)

Refined final version with complete documentation.

## What This Unit Covers

- Code organisation and commenting
- Consistent formatting throughout
- All features fully integrated
- Production-ready game code
- Complete feature set

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware.

### Controls

| Key | Action |
|-----|--------|
| X | Hit notes on track 1 |
| C | Hit notes on track 2 |
| V | Hit notes on track 3 |
| P | Pause/unpause |
| SPACE | Start game / return to title |

## Complete Feature List

- Three-track rhythm gameplay with SID audio
- Timing grades (Perfect/Good/Late) with visual feedback
- Combo system with score multiplier (1x-4x)
- Dynamic difficulty progression
- High score tracking
- Pause functionality
- Visual juice (border flash effects)
- Full game loop (title, play, game over, victory)

## Code Organisation

The final code is organised into clear sections:

1. **Constants** - Memory addresses, colours, timing values
2. **BASIC stub** - SYS launch point
3. **Main loop** - State machine and game flow
4. **Initialisation** - Screen, SID, game state setup
5. **Input handling** - Keyboard scanning
6. **Game logic** - Notes, scoring, difficulty
7. **Display** - Screen updates, effects
8. **Audio** - SID voice control
9. **Data** - Song data, lookup tables
10. **Variables** - Game state storage

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
