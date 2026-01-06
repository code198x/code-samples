# Unit 4: Claiming Cells

Player claims neutral cells on the board.

## What This Unit Covers

- SPACE key detection for claiming
- Cell ownership tracking
- Attribute colour change on claim
- Board state array management

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator. Move cursor with Q/A/O/P and press SPACE to claim cells (turns red).

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Cell ownership | 0=neutral, 1=player 1, 2=player 2 |
| Board array | 64-byte array tracks cell states |
| Claim validation | Only neutral cells can be claimed |
| Colour mapping | Owner determines cell colour |

## Cell Colours

| Owner | Colour |
|-------|--------|
| Neutral | White |
| Player 1 | Red |
| Player 2 | Cyan |

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
