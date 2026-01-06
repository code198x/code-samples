# Unit 10: Jump Animation

Different sprite when jumping.

## What This Unit Covers

- State-based animation
- Jump vs fall frames
- Animation priority

## Key Concepts

| Concept | Description |
|---------|-------------|
| Player state | Grounded, jumping, falling |
| State priority | Air state overrides walk |
| Jump frame | Legs tucked |
| Fall frame | Arms up or legs extended |

## State-Based Tiles

```asm
TILE_STAND  = $00
TILE_JUMP   = $08
TILE_FALL   = $0A

get_animation_tile:
    ; Check if in air
    lda player_grounded
    bne @grounded

    ; In air - jump or fall?
    lda player_vel_y
    bmi @jumping
    ; Falling
    lda #TILE_FALL
    rts

@jumping:
    lda #TILE_JUMP
    rts

@grounded:
    ; Use walk animation
    ldx anim_frame
    lda walk_frames,x
    rts
```

## Animation Selection

```asm
update_animation:
    ; Get base tile for current state
    jsr get_animation_tile
    sta current_tile

    ; Update all sprite tiles
    jsr update_player_tiles
    rts
```

## Expected Result

Player shows jump pose when rising, fall pose when descending.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
