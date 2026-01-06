# Unit 12: Title Screen

Title display and game state management.

## What This Unit Covers

- Title screen display
- Game state machine
- Key wait for game start
- State transitions

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator. Title screen shows until SPACE pressed.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Game states | Title, playing, game over |
| State variable | Tracks current game mode |
| State handlers | Different code per state |
| Clean restart | Reset all variables for new game |

## Game States

| State | Value | Description |
|-------|-------|-------------|
| Title | 0 | Show title, wait for SPACE |
| Playing | 1 | Active gameplay |
| Game Over | 2 | Show result, wait for restart |

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
