# Unit 14: Pause

Pause functionality with START button.

## What This Unit Covers

- Pause state flag
- Button edge detection
- Game freeze during pause
- Pause indicator display

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. Press START to pause/unpause.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Pause flag | Skip updates when set |
| Edge trigger | Detect button press, not hold |
| Previous state | Compare current vs last frame |
| Audio mute | Silence APU during pause |

## Pause Toggle

```asm
check_pause:
    lda buttons
    and #BUTTON_START
    beq @not_pressed
    lda buttons_prev
    and #BUTTON_START
    bne @already_held
    ; Toggle pause
    lda paused
    eor #$01
    sta paused
@already_held:
@not_pressed:
    rts
```

## Pause Handling

```asm
main_loop:
    lda paused
    bne @skip_updates
    jsr move_player
    jsr move_enemies
    jsr check_collisions
@skip_updates:
    jsr render
    jmp main_loop
```

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
