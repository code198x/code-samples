# Lesson 1 Code Samples: Hello, Computer

## Files in this directory

### example-1.bas - Simple Hello Program
First BASIC program - displays a message and ends politely.
- Demonstrates: PRINT, END
- Lines: 2
- Type: Basic example

### example-2.bas - Infinite Text Scroll (WOW Moment)
Creates an endless loop that fills the screen with text.
- Demonstrates: PRINT, GOTO loop, RUN/STOP escape
- Lines: 2
- Type: WOW moment
- Note: Press RUN/STOP (C64) or Esc (VICE) to halt

## Validation

All programs validated with:
```bash
petcat -w2 -o example-1.prg -- example-1.bas
petcat -w2 -o example-2.prg -- example-2.bas
```

## Testing

```bash
# Quick test in VICE
../../../../../../scripts/quick-vice.sh example-1.bas
../../../../../../scripts/quick-vice.sh example-2.bas
```
