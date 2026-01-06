# Unit 14: Player-Enemy Collision

Handle player touching enemies.

## What This Unit Covers

- Bounding box collision
- Jump-on-enemy mechanic
- Damage vs defeat

## Key Concepts

| Concept | Description |
|---------|-------------|
| Overlap test | Bounding box intersection |
| Top collision | Player stomps enemy |
| Side collision | Player takes damage |
| Defeat | Remove enemy, award points |

## Collision Check

```asm
check_enemy_collisions:
    lda player_invuln
    bne @done

    ldx #0

@loop:
    lda enemy_active,x
    beq @next

    ; Check X overlap
    lda player_x
    sec
    sbc enemy_x,x
    bpl @check_pos_x
    eor #$FF
    clc
    adc #1                  ; Absolute value

@check_pos_x:
    cmp #16                 ; Combined widths
    bcs @next               ; No X overlap

    ; Check Y overlap
    lda player_y
    sec
    sbc enemy_y,x
    bpl @check_pos_y
    eor #$FF
    clc
    adc #1

@check_pos_y:
    cmp #16
    bcs @next               ; No Y overlap

    ; Collision! Check if stomping
    lda player_vel_y
    bmi @hit_player         ; Moving up = hit
    lda player_y
    clc
    adc #12                 ; Player's feet
    cmp enemy_y,x
    bcs @hit_player         ; Feet below enemy top

    ; Stomp!
    jsr defeat_enemy
    bra @done

@hit_player:
    jsr player_take_damage

@next:
    inx
    cpx #MAX_ENEMIES
    bne @loop

@done:
    rts
```

## Defeat Enemy

```asm
defeat_enemy:
    ; Deactivate enemy
    lda #0
    sta enemy_active,x

    ; Bounce player
    lda #-4
    sta player_vel_y

    ; Add score
    ; ...
    rts
```

## Expected Result

Jumping on enemies defeats them. Side collision damages player.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
