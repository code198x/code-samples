# Unit 13: Two Player Mode

Human vs human hotseat gameplay.

## What This Unit Covers

- Game mode selection
- Two human players
- Mode-specific handling
- Player type tracking

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator. Select 1 Player (vs AI) or 2 Player mode from menu.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Mode selection | Menu before game starts |
| Player type array | Track human/AI per player |
| Mode variable | Single flag for game mode |
| Shared input | Same controls work for both players |

## Game Modes

| Mode | Player 1 | Player 2 |
|------|----------|----------|
| 1 Player | Human | AI |
| 2 Player | Human | Human |

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
