# Unit 5: Player Movement

Combine joystick input with sprite positioning.

## What This Unit Covers

- Main game loop structure
- Updating sprite position from input
- Movement speed control

## Key Concepts

| Concept | Description |
|---------|-------------|
| Game loop | Read input → Update → Render → Repeat |
| Position variables | Store X/Y in zero page for speed |
| Movement speed | Pixels per frame (start with 2) |

## Movement Logic

```asm
read_joystick:
    lda $DC00
    lsr
    bcs not_up
    dec player_y        ; Move up
not_up:
    lsr
    bcs not_down
    inc player_y        ; Move down
not_down:
    ; ... left/right similar
```

## Expected Result

Player ship moves in all four directions with joystick input.

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
