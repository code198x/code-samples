# Unit 14: Difficulty Levels

Configurable AI difficulty settings.

## What This Unit Covers

- Difficulty menu selection
- AI behaviour modification
- Thinking time variation
- Strategic depth levels

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator. In 1 Player mode, select Easy, Normal, or Hard difficulty.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Difficulty variable | 0=Easy, 1=Normal, 2=Hard |
| AI parameter lookup | Tables hold difficulty settings |
| Random factor | Lower difficulty adds randomness |
| Think time | Harder AI thinks longer |

## Difficulty Settings

| Level | Randomness | Think Time | Strategy |
|-------|------------|------------|----------|
| Easy | High | Fast | Random moves |
| Normal | Medium | Medium | Some strategy |
| Hard | None | Slow | Best moves |

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
