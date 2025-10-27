# Lesson 004: VBlank Timing

Code samples for NES VBlank synchronization and NMI interrupt handling.

## Files

- `nmi-handler.asm` - Basic NMI handler structure with register preservation
- `colour-cycle.asm` - Colour cycling demonstration at 60fps

## Building

```bash
ca65 nmi-handler.asm -o nmi-handler.o
ld65 nmi-handler.o -C nes.cfg -o nmi-handler.nes

ca65 colour-cycle.asm -o colour-cycle.o
ld65 colour-cycle.o -C nes.cfg -o colour-cycle.nes
```

## Testing

**nmi-handler.nes** - Displays blue screen with proper 60fps timing
**colour-cycle.nes** - Background cycles through 8 colours (15 frames each colour)

## Key Concepts

### NMI (Non-Maskable Interrupt)

Hardware interrupt triggered at start of VBlank (60 times per second). CPU jumps to NMI handler automatically.

### VBlank Period

Time when TV electron beam returns to top (~2273 CPU cycles). Safe to update PPU during this window.

### Register Preservation

NMI can interrupt main code at any time. Must save A, X, Y at start and restore before RTI.

### Game Loop Structure

- **MainLoop**: Game logic (input, physics, AI)
- **NMI Handler**: Graphics updates (sprites, palette, scroll)
- **Flag synchronization**: `nmi_ready` coordinates the two

### Timing

- **Frame time**: 16.67ms (NTSC 60 Hz)
- **VBlank**: ~2273 cycles available
- **Active display**: ~29658 cycles (CPU runs game logic)

## Common Patterns

### Basic NMI Structure
```asm
NMI:
    PHA                 ; Save A
    TXA
    PHA                 ; Save X
    TYA
    PHA                 ; Save Y

    ; Graphics updates here

    PLA
    TAY                 ; Restore Y
    PLA
    TAX                 ; Restore X
    PLA                 ; Restore A
    RTI                 ; Return from interrupt
```

### Main Loop Sync
```asm
MainLoop:
:   LDA nmi_ready       ; Wait for NMI
    BEQ :-
    LDA #$00
    STA nmi_ready       ; Reset flag
    ; Game logic here
    JMP MainLoop
```

### Enabling NMI
```asm
LDA #%10000000          ; Bit 7 = NMI enable
STA $2000               ; PPUCTRL
```
