# Unit 6: Valid Moves

Move validation with adjacency checking.

## What This Unit Covers

- Adjacency detection (4 directions)
- Valid move rules enforcement
- Visual feedback for invalid moves
- Conversion of enemy cells

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator. Players can only claim neutral cells adjacent to their own, or convert enemy cells.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Adjacency check | Test cells at (x±1, y) and (x, y±1) |
| Move validation | Must be adjacent to owned cell |
| Cell conversion | Claim enemy cell if adjacent to yours |
| Invalid feedback | Flash border or play sound on invalid |

## Move Rules

1. **Claim neutral**: Cell must be adjacent to your territory
2. **Convert enemy**: Cell must be adjacent to your territory
3. **Cannot claim**: Own cells or non-adjacent cells

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
