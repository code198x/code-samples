# Unit 7: Simple AI

Basic AI opponent with random move selection.

## What This Unit Covers

- AI turn handling
- Random number generation
- Valid move search for AI
- AI thinking delay

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator. Player 1 is human, Player 2 is AI making random valid moves.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Random seed | R register provides pseudo-random values |
| Move search | Scan board for valid AI moves |
| AI delay | HALT loops simulate "thinking" |
| Player type | Flag distinguishes human vs AI |

## AI Algorithm

```
1. Build list of all valid moves
2. Pick random index into list
3. Execute selected move
4. Wait for thinking delay
```

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
