# Unit 9: Win Detection

Game-over condition detection and winner determination.

## What This Unit Covers

- End game condition checking
- No valid moves detection
- Territory counting for winner
- Game-over display

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator. Game ends when a player has no valid moves. Winner has more territory.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Move availability | Check if current player has any moves |
| Pass turn | Skip turn if no moves available |
| Game over | Both players have no moves |
| Territory count | Sum cells owned by each player |

## Win Conditions

1. Opponent has no valid moves and you do
2. Both players have no moves - most territory wins
3. Tie if equal territory

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
