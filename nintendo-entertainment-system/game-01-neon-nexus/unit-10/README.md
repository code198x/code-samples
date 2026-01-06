# Unit 10: Sound Effects

APU audio for game feedback.

## What This Unit Covers

- APU channel configuration
- Pulse wave sound effects
- Noise channel for impacts
- Sound triggering system

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. Sounds play on collect, death, and game events.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| APU channels | 2 pulse, 1 triangle, 1 noise, 1 DMC |
| Duty cycle | Pulse wave shape (12.5%, 25%, 50%, 75%) |
| Length counter | Auto-stop after duration |
| Volume envelope | Decay or constant volume |

## Playing a Sound

```asm
play_collect:
    lda #%10011111      ; Duty 50%, constant vol 15
    sta APU_PULSE1_CTRL
    lda #$00
    sta APU_PULSE1_SWEEP
    lda #$70            ; Frequency low
    sta APU_PULSE1_LO
    lda #$08            ; Frequency high + length
    sta APU_PULSE1_HI
    rts
```

## Sound Effects

| Event | Channel | Character |
|-------|---------|-----------|
| Collect | Pulse 1 | High blip |
| Death | Noise | Low crash |
| Level up | Pulse 1+2 | Arpeggio |

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
