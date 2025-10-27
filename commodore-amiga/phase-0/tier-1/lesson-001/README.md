# Lesson 001: Hello, Amiga

Your first AMOS Professional program - an infinite counter.

## Files

- `hello-amiga.amos` - Infinite counter with Locate positioning

## Concepts

- **Structured programming**: No line numbers, modern syntax
- **Variables**: Store and update values (`count`)
- **Locate**: Position text at row/column coordinates
- **Repeat...Until**: Loop structure (infinite with `Until False`)
- **Comments**: Use single quote `'` (not REM)

## Key Points

AMOS Professional is fundamentally different from traditional BASIC:
- No line numbers required
- Compiled internally for fast execution
- Modern structured syntax (procedures, labels)
- `Locate row,column` for text positioning (0-based)

## Running

1. Load AMOS Professional on Amiga
2. Load `hello-amiga.amos`
3. Press F1 to run
4. Press Ctrl+C to stop the infinite loop

## Extensions

Try modifying:
- Starting number: `count=100`
- Increment: `count=count+10` (count by tens)
- Count backwards: `count=count-1`
- Position: `Locate 5,20` (different location)
- Add `Wait Vbl` after Print to slow down
- Add `Cls 0` at start to clear screen to black
- Use `Ink 2 : Print count` to change text colour
