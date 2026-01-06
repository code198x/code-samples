# Unit 6: Screen Boundaries

Keep the player ship within the playfield.

## What This Unit Covers

- Boundary checking before movement
- Screen coordinate limits
- Handling X high bit for full width

## Key Concepts

| Concept | Description |
|---------|-------------|
| Minimum Y | ~50 (top of visible area) |
| Maximum Y | ~229 (bottom minus sprite height) |
| Minimum X | ~24 (left edge) |
| Maximum X | ~320 (right edge, requires high bit) |

## Boundary Check Pattern

```asm
check_up:
    lda player_y
    cmp #50             ; Top boundary
    bcc skip_up         ; Already at top
    dec player_y
skip_up:
```

## Expected Result

Player ship cannot move outside the visible screen area.

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
