# Unit 16: Final Polish

Complete game with title screen and audio.

## What This Unit Covers

- Title screen state
- Game over screen
- SID sound effects
- Final balancing

## Key Concepts

| Concept | Description |
|---------|-------------|
| Game states | Title, Playing, Game Over |
| State machine | Switch logic based on state |
| SID effects | Shoot sound, explosion sound |
| Polish | Timing, feel, presentation |

## Game States

```asm
STATE_TITLE     = 0
STATE_PLAYING   = 1
STATE_GAMEOVER  = 2

game_state:     !byte STATE_TITLE

main_loop:
    lda game_state
    cmp #STATE_TITLE
    beq do_title
    cmp #STATE_PLAYING
    beq do_playing
    jmp do_gameover
```

## Sound Effects

```asm
play_shoot:
    lda #$0F
    sta $D418           ; Volume
    lda #$81
    sta $D405           ; Attack/Decay
    lda #$20
    sta $D400           ; Frequency low
    lda #$10
    sta $D401           ; Frequency high
    lda #$81
    sta $D404           ; Waveform + gate
    rts
```

## Complete Feature List

- Title screen with "PRESS FIRE"
- Player ship with 4-directional movement
- Multiple bullets in flight
- 3 enemies per wave
- Hardware collision detection
- Score display
- Lives system
- Wave progression with difficulty scaling
- SID sound effects
- Game over screen

## Building

```bash
acme -f cbm -o starfield.prg starfield.asm
```

## Running

```bash
x64sc starfield.prg
```

## Files

- `starfield.asm` - Assembly source
- `starfield.prg` - Compiled executable
