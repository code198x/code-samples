# Unit 12: Enemy Sprites

Add enemy characters to the level.

## What This Unit Covers

- Enemy sprite data
- Enemy positioning
- Multiple enemy support

## Key Concepts

| Concept | Description |
|---------|-------------|
| Enemy OAM | Sprites 4+ for enemies |
| Enemy state | Active, position, type |
| Metasprite | 8×8 or 16×16 enemies |
| Enemy count | Limited by OAM (64 sprites total) |

## Enemy Data

```asm
MAX_ENEMIES = 4

enemy_active:   .res MAX_ENEMIES
enemy_x:        .res MAX_ENEMIES
enemy_y:        .res MAX_ENEMIES
enemy_type:     .res MAX_ENEMIES
```

## Enemy Sprites

```asm
ENEMY_OAM_START = $0210     ; After player sprites

update_enemy_sprites:
    ldx #0                  ; Enemy index
    ldy #0                  ; OAM offset

@loop:
    lda enemy_active,x
    beq @skip

    ; Y position
    lda enemy_y,x
    sta ENEMY_OAM_START,y

    ; Tile (based on type)
    lda enemy_type,x
    asl a
    asl a                   ; × 4 for tile index
    clc
    adc #$20                ; Enemy tile base
    sta ENEMY_OAM_START+1,y

    ; Attributes
    lda #$01                ; Palette 1
    sta ENEMY_OAM_START+2,y

    ; X position
    lda enemy_x,x
    sta ENEMY_OAM_START+3,y

@skip:
    iny
    iny
    iny
    iny                     ; Next OAM entry
    inx
    cpx #MAX_ENEMIES
    bne @loop
    rts
```

## Expected Result

Enemy characters visible at their starting positions.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
