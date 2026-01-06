# Unit 2: Player Sprite

Display the player ship using hardware sprite.

## What This Unit Covers

- Hardware sprite structure
- Sprite DMA setup
- Positioning the sprite

## Key Concepts

| Concept | Description |
|---------|-------------|
| Sprite data | Control words + image data |
| SPRPT registers | Pointer to sprite data |
| Position encoding | X in HSTART, Y in VSTART/VSTOP |
| Sprite colours | SPR0DAT colour registers |

## Sprite Structure

```asm
player_sprite:
    dc.w    $6050,$7800         ; VSTART, HSTART, VSTOP
    dc.w    %0000011111100000   ; Row 1
    dc.w    %0000000000000000
    dc.w    %0001111111111000   ; Row 2
    dc.w    %0000000000000000
    ; ... more rows
    dc.w    0,0                 ; End of sprite
```

## Sprite Setup

```asm
    lea     player_sprite,a0
    move.l  a0,SPR0PTH          ; Point sprite 0

    move.w  #$0FFF,COLOR17      ; Sprite colour 1: white
    move.w  #$00FF,COLOR18      ; Sprite colour 2: blue
    move.w  #$0F00,COLOR19      ; Sprite colour 3: red
```

## Expected Result

Player ship sprite visible on the dark background.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
