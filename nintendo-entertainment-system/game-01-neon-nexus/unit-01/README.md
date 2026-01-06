# Unit 1: The Grid

Basic PPU setup and background rendering.

## What This Unit Covers

- iNES ROM header format
- NES startup sequence
- PPU register configuration
- Nametable background drawing
- Palette loading

## Building

```bash
ca65 nexus.asm -o nexus.o
ld65 -C nes.cfg nexus.o -o nexus.nes
```

## Running

Load `nexus.nes` in an emulator. A background grid pattern displays.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| iNES header | 16-byte header with ROM configuration |
| PPU warmup | Two VBlank waits before PPU access |
| PPUADDR | Write address high then low byte |
| PPUDATA | Sequential writes to PPU memory |

## NES Startup

```asm
reset:
    sei             ; Disable IRQ
    cld             ; Clear decimal mode
    ldx #$40
    stx $4017       ; Disable APU frame IRQ
    ldx #$ff
    txs             ; Setup stack
    inx
    stx PPUCTRL     ; Disable NMI
    stx PPUMASK     ; Disable rendering
```

## Files

- `nexus.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `nexus.nes` - Compiled ROM
