# Unit 13: Enemy Variety

Multiple enemy types with different behaviours.

## What This Unit Covers

- Enemy type variable
- Different movement patterns
- Vertical bouncing enemies
- Type-specific sprites

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. Different enemy types move in distinct patterns.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Type array | Stores behaviour type per enemy |
| Pattern dispatch | Branch to movement by type |
| Bounce logic | Reverse velocity at boundaries |
| Tile selection | Different sprite per type |

## Enemy Types

| Type | Movement | Sprite |
|------|----------|--------|
| 0 | Horizontal | Circle |
| 1 | Vertical | Square |
| 2 | Diagonal | Diamond |
| 3 | Chase | Star |

## Type-Based Movement

```asm
move_enemy:
    lda enemy_type,x
    cmp #TYPE_HORIZONTAL
    beq @horizontal
    cmp #TYPE_VERTICAL
    beq @vertical
    cmp #TYPE_DIAGONAL
    beq @diagonal
    jmp @chase
```

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
