# Unit 8: Lives

Lives system with respawning.

## What This Unit Covers

- Lives counter
- Death handling
- Respawn sequence
- Lives display
- Game over trigger

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. Lives shown in HUD; game ends when all lost.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Lives variable | Starts at 3, decrements on death |
| Invulnerability | Brief immunity after respawn |
| Death animation | Flash or disappear effect |
| Game over check | Test lives for zero |

## Death Handling

```asm
player_death:
    dec lives
    beq @game_over
    ; Respawn player
    lda #128
    sta player_x
    lda #120
    sta player_y
    lda #60             ; 1 second immunity
    sta invulnerable
    rts
@game_over:
    lda #STATE_GAMEOVER
    sta game_state
    rts
```

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
