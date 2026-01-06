# Unit 15: Level Exit

Complete the level by reaching the goal.

## What This Unit Covers

- Exit tile/zone
- Level completion
- Transition to next level

## Key Concepts

| Concept | Description |
|---------|-------------|
| Exit zone | Special tile or area |
| Completion check | Player overlaps exit |
| Level transition | Load next level data |
| Victory feedback | Sound, animation |

## Exit Detection

```asm
TILE_EXIT = $1F

exit_x:         .res 1
exit_y:         .res 1
level_number:   .res 1

check_exit:
    ; Check if player reached exit
    lda player_x
    sec
    sbc exit_x
    bpl @check_pos_x
    eor #$FF
    clc
    adc #1

@check_pos_x:
    cmp #16
    bcs @not_at_exit

    lda player_y
    sec
    sbc exit_y
    bpl @check_pos_y
    eor #$FF
    clc
    adc #1

@check_pos_y:
    cmp #16
    bcs @not_at_exit

    ; At exit!
    jsr level_complete

@not_at_exit:
    rts
```

## Level Complete

```asm
level_complete:
    ; Play victory sound
    jsr play_victory_sound

    ; Increment level
    inc level_number

    ; Check for game complete
    lda level_number
    cmp #MAX_LEVELS
    bcs @game_complete

    ; Load next level
    jsr load_level
    jsr reset_player

    rts

@game_complete:
    lda #STATE_VICTORY
    sta game_state
    rts
```

## Expected Result

Reaching the exit area completes the level and advances to the next.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
