# Unit 15: Game Over Polish

Visual polish effects for game over.

## What This Unit Covers

- Screen flash effect
- Input delay on game over
- Smooth transitions
- Sound feedback

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. Game over has flash effect and delay before restart.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Palette flash | Cycle emphasis bits |
| Input delay | Timer before accepting input |
| Fade timing | Frame-based colour transitions |
| Polish timing | Small delays feel intentional |

## Screen Flash

```asm
flash_screen:
    lda #%11100000      ; All emphasis bits
    sta PPUMASK
    ldx #10
@delay:
    jsr wait_vblank
    dex
    bne @delay
    lda #%00011110      ; Normal rendering
    sta PPUMASK
    rts
```

## Input Delay

```asm
game_over_init:
    lda #90             ; 1.5 seconds
    sta input_delay
    rts

game_over_update:
    lda input_delay
    beq @accept_input
    dec input_delay
    rts
@accept_input:
    ; Check for START
```

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
