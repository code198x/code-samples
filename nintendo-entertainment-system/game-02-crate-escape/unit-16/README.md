# Unit 16: Final Polish

Complete game with title screen, lives, and audio.

## What This Unit Covers

- Title screen
- Lives display
- APU sound effects
- Final balancing

## Key Concepts

| Concept | Description |
|---------|-------------|
| Game states | Title, Playing, Game Over, Victory |
| Lives display | HUD at top of screen |
| APU | Sound effects for actions |
| Polish | Timing, feedback, feel |

## Game States

```asm
STATE_TITLE     = 0
STATE_PLAYING   = 1
STATE_GAMEOVER  = 2
STATE_VICTORY   = 3

game_state:     .res 1

main_loop:
    jsr wait_nmi

    lda game_state
    cmp #STATE_TITLE
    beq do_title
    cmp #STATE_PLAYING
    beq do_playing
    cmp #STATE_GAMEOVER
    beq do_gameover
    jmp do_victory
```

## APU Sound Effects

```asm
; Pulse channel 1 for jump
play_jump_sound:
    lda #%10111111          ; Duty, length counter halt, volume
    sta $4000
    lda #$C9                ; Frequency low
    sta $4002
    lda #%00001000          ; Frequency high, length counter
    sta $4003
    rts

; Noise channel for landing
play_land_sound:
    lda #%00111111
    sta $400C
    lda #%00000101          ; Noise period
    sta $400E
    lda #%00001000
    sta $400F
    rts
```

## Lives Display

```asm
lives:          .res 1

draw_lives:
    ; Draw heart icons for each life
    lda #$20
    sta PPUADDR
    lda #$02                ; Position
    sta PPUADDR

    ldx lives
@loop:
    lda #TILE_HEART
    sta PPUDATA
    dex
    bne @loop
    rts
```

## Complete Feature List

- Title screen with "Press START"
- Player movement with D-pad
- Jump with A button (variable height)
- Gravity and platform collision
- Walk and jump animations
- Hazards (spikes, pits)
- Patrolling enemies
- Stomp to defeat enemies
- Multiple levels
- Exit goal
- Lives system
- APU sound effects
- Game over and victory screens

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Running

Load `crate.nes` in Mesen or another NES emulator.

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
