# Unit 4: The Traffic

Blitter operations for drawing cars.

## What This Unit Covers

- Blitter hardware overview
- Bitplane graphics concepts
- Cookie-cut blitting (masked copy)
- Blitter wait synchronisation

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator. Cars appear on the road lanes.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Blitter | Hardware block transfer unit |
| BLTCON0/1 | Blitter control registers |
| Source/Dest | A, B, C sources and D destination |
| Modulo | Bytes to skip between rows |

## Blitter Setup

```asm
move.w  #$7fff,DMACON(a5)
waitblit:
    btst    #6,DMACONR(a5)
    bne.s   waitblit
move.l  #car_data,BLTAPTH(a5)
move.l  #screen+offset,BLTDPTH(a5)
move.w  #(height<<6)|words,BLTSIZE(a5)
```

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
