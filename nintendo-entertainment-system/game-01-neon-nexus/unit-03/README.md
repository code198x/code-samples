# Unit 3: Movement

Controller reading and player movement.

## What This Unit Covers

- Controller port reading via $4016
- Button state extraction
- Player position updates
- Boundary checking

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. Use D-pad to move the player.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Controller strobe | Write 1 then 0 to $4016 |
| Button read | Read $4016 eight times for buttons |
| Button order | A, B, Select, Start, Up, Down, Left, Right |
| Movement speed | Add/subtract from position per frame |

## Controller Reading

```asm
read_controller:
    lda #$01
    sta JOYPAD1     ; Begin strobe
    lda #$00
    sta JOYPAD1     ; End strobe
    ldx #$08
@loop:
    lda JOYPAD1
    lsr a           ; Bit 0 to carry
    rol buttons     ; Carry to buttons
    dex
    bne @loop
```

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
