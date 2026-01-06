# Unit 5: Turn Logic

Turn-based gameplay with player switching.

## What This Unit Covers

- Current player tracking
- Turn switching after claim
- Player indicator display
- Turn-specific cursor colours

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator. Players alternate turns: claim a cell, control passes to opponent.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Current player | Variable tracks whose turn it is |
| Turn switch | XOR with 3 toggles between 1 and 2 |
| Player display | Show "PLAYER 1" or "PLAYER 2" |
| Cursor colour | Matches current player |

## Turn Flow

1. Display current player
2. Wait for valid claim
3. Update board state
4. Switch to other player
5. Repeat

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
