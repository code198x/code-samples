# Unit 6: Collision

Sprite collision detection system.

## What This Unit Covers

- Bounding box collision
- Player-enemy collision
- Player-item collision
- Collision response

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. Collect items and avoid enemies.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| AABB test | Axis-aligned bounding box overlap |
| Distance check | Compare absolute differences |
| Hit response | Different actions for enemy vs item |
| Collision size | 8x8 or 16x16 pixel hitboxes |

## Collision Check

```asm
check_collision:
    ; Check X overlap
    lda player_x
    sec
    sbc enemy_x
    bpl @positive_x
    eor #$ff
    clc
    adc #1
@positive_x:
    cmp #8              ; 8 pixel threshold
    bcs @no_collision
    ; Same for Y...
    lda #1              ; Collision!
    rts
@no_collision:
    lda #0
    rts
```

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
