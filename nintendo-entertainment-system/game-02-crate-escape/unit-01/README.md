# Unit 1: Display Setup

Initialise the PPU for game display.

## What This Unit Covers

- NES startup sequence
- PPU register configuration
- Palette loading

## Key Concepts

| Concept | Description |
|---------|-------------|
| Reset vector | Entry point at $FFFC |
| PPU warmup | Wait for 2 VBlanks |
| PPUCTRL | $2000 - NMI enable, pattern tables |
| PPUMASK | $2001 - Rendering enable |
| Palette | 32 bytes at $3F00 |

## Startup Sequence

```asm
reset:
    sei                 ; Disable IRQs
    cld                 ; Clear decimal mode
    ldx #$40
    stx $4017           ; Disable APU frame IRQ

    ldx #$FF
    txs                 ; Setup stack

    inx                 ; X = 0
    stx PPUCTRL         ; Disable NMI
    stx PPUMASK         ; Disable rendering
    stx $4010           ; Disable DMC IRQs

    ; Wait for first VBlank
@vblank1:
    bit PPUSTATUS
    bpl @vblank1

    ; Clear RAM
    lda #$00
@clear:
    sta $0000,x
    sta $0100,x
    sta $0200,x
    ; ... etc
    inx
    bne @clear

    ; Wait for second VBlank
@vblank2:
    bit PPUSTATUS
    bpl @vblank2
```

## Expected Result

NES initialised and ready for graphics. Black screen with PPU configured.

## Building

```bash
ca65 crate.asm -o crate.o
ld65 -C nes.cfg crate.o -o crate.nes
```

## Files

- `crate.asm` - Assembly source
- `nes.cfg` - Linker configuration
- `crate.nes` - Compiled ROM
