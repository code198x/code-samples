# Unit 11: Sound Effects

Beeper sound generation for game feedback.

## What This Unit Covers

- ZX Spectrum beeper output
- Frequency generation via loops
- Sound for different events
- Duration control

## Building

```bash
pasmonext --tapbas inkwar.asm inkwar.tap
```

## Running

Load `inkwar.tap` in an emulator. Sounds play on cell claims, invalid moves, and game over.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| OUT (254) | Bit 4 controls speaker |
| Frequency loop | Toggle speaker, delay, repeat |
| Pitch control | Shorter delay = higher pitch |
| Duration | More iterations = longer sound |

## Sound Events

| Event | Pitch | Duration |
|-------|-------|----------|
| Claim cell | Medium | Short |
| Invalid move | Low | Short |
| Win | High ascending | Long |
| Lose | Low descending | Long |

## Files

- `inkwar.asm` - Assembly source
- `inkwar.tap` - TAP file for emulators
