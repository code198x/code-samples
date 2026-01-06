# Unit 4: Keeping Score

16-bit score tracking with decimal display conversion.

## What This Unit Covers

- 16-bit addition for scores exceeding 255
- Binary to decimal conversion (repeated subtraction)
- Score and streak display rendering
- Working memory for conversion calculations
- Digit-by-digit screen output

## Building

```bash
acme -f cbm -o symphony.prg symphony.asm
```

## Running

Load `symphony.prg` in VICE or on real hardware. Press **X** to hit notes and earn 10 points per hit. Score and streak display at top of screen.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| 16-bit arithmetic | score_lo/score_hi pair for values 0-65535 |
| BCD conversion | Subtract powers of 10 to extract digits |
| Screen codes | OR with $30 converts 0-9 to displayable digits |
| Streak tracking | Consecutive hit counter, resets on miss |

## Files

- `symphony.asm` - Assembly source
- `symphony.prg` - Compiled C64 executable
