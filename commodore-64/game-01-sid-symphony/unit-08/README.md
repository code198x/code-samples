# Unit 8: The Performance

State machine architecture with complete game loop.

## What This Unit Covers

- Game state machine (title, playing, game over, victory)
- State-specific screen drawing
- State transition logic
- Full game restart capability
- SPACE key for navigation

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware.

- **SPACE** - Start game from title / return to title after game over
- **X/C/V** - Hit notes during gameplay

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| State variable | game_state holds current mode (0-3) |
| Jump table | Branch to state-specific update routine |
| State screens | Different draw routines per state |
| Clean restart | Reset all game variables on new game |

## Game States

| State | Value | Description |
|-------|-------|-------------|
| Title | 0 | Show title screen, wait for SPACE |
| Playing | 1 | Active gameplay |
| Game Over | 2 | Crowd depleted, show final score |
| Victory | 3 | Song completed, show results |

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
