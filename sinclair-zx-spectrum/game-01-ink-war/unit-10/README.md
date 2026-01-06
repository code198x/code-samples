# Unit 10: Scoring

Territory counting with live score display.

## What This Unit Covers

- Cell counting per player
- Score display formatting
- Binary to ASCII conversion
- Real-time score updates

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator. Scores update as players claim territory.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Cell iteration | Loop through 64 board cells |
| Owner comparison | Compare cell value to player number |
| Score counters | Track count for each player |
| Number display | Convert binary to ASCII digits |

## Score Display

```
Player 1: 12    Player 2: 08
```

Scores shown at top of screen, updated after each move.

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
