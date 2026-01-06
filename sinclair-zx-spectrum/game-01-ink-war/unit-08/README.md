# Unit 8: Better AI

Improved AI with strategic scoring heuristics.

## What This Unit Covers

- Move scoring system
- Strategic evaluation factors
- Best move selection
- Corner and edge priorities

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator. The AI now makes smarter moves based on strategic evaluation.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Move scoring | Each valid move gets a score |
| Position value | Corners worth more than edges |
| Neighbour count | More friendly neighbours = better |
| Best selection | Choose highest-scoring move |

## Scoring Factors

| Factor | Points |
|--------|--------|
| Corner cell | +3 |
| Edge cell | +1 |
| Each friendly neighbour | +1 |
| Converts enemy cell | +2 |

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
