# Unit 11: Hazards

Add dangerous tiles that hurt the player.

## What This Unit Covers

- Hazard tile types
- Collision with hazards
- Damage response

## Key Concepts

| Concept | Description |
|---------|-------------|
| Hazard tiles | Spikes, pits |
| Collision check | Player overlaps hazard |
| Damage | Lose life, respawn |
| Invulnerability | Brief protection after hit |

## Hazard Detection

```asm
TILE_SPIKE  = $10
TILE_PIT    = $FF           ; Special case

check_hazards:
    ; Check tile at player's feet
    lda player_x
    clc
    adc #8                  ; Centre
    jsr pixel_to_tile
    tax

    lda player_y
    clc
    adc #15                 ; Bottom
    jsr pixel_to_tile
    tay

    jsr get_tile_at
    cmp #TILE_SPIKE
    beq @hit_hazard

    ; Check for pit (fell off bottom)
    lda player_y
    cmp #224
    bcs @hit_hazard

    rts

@hit_hazard:
    jsr player_take_damage
    rts
```

## Damage Response

```asm
player_invuln:  .res 1

player_take_damage:
    ; Check invulnerability
    lda player_invuln
    bne @done

    ; Lose a life
    dec lives
    beq @game_over

    ; Set invulnerability
    lda #120                ; 2 seconds
    sta player_invuln

    ; Respawn at checkpoint
    jsr respawn_player

@done:
    rts

@game_over:
    lda #STATE_GAMEOVER
    sta game_state
    rts
```

## Expected Result

Touching spikes or falling in pits causes damage and respawn.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
