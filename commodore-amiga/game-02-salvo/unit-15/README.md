# Unit 15: Lives and Audio

Add lives display and Paula sound effects.

## What This Unit Covers

- Lives counter display
- Game over condition
- Paula audio for events

## Key Concepts

| Concept | Description |
|---------|-------------|
| Lives | Start with 3 |
| Display | Ship icons or number |
| Game over | Lives = 0 |
| Paula | Sample playback for effects |

## Lives Display

```asm
lives:          dc.b    3

draw_lives:
    moveq   #0,d0
    move.b  lives,d0
    ; Draw ship icons for each life
    rts

check_game_over:
    tst.b   lives
    bne.s   .playing
    move.b  #STATE_GAMEOVER,game_state
.playing:
    rts
```

## Paula Sound Effects

```asm
AUD0LC  = $DFF0A0
AUD0LEN = $DFF0A4
AUD0PER = $DFF0A6
AUD0VOL = $DFF0A8

play_shoot:
    lea     shoot_sample,a0
    move.l  a0,AUD0LC
    move.w  #SHOOT_LEN/2,AUD0LEN
    move.w  #300,AUD0PER        ; Pitch
    move.w  #64,AUD0VOL         ; Max volume
    move.w  #$8001,DMACON       ; Enable audio 0
    rts

play_explosion:
    lea     explosion_sample,a0
    move.l  a0,AUD0LC
    move.w  #EXPLODE_LEN/2,AUD0LEN
    move.w  #200,AUD0PER
    move.w  #64,AUD0VOL
    move.w  #$8001,DMACON
    rts
```

## Expected Result

Lives shown on screen. Sound effects for shooting and explosions. Game over when lives exhausted.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
