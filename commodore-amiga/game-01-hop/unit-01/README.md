# Unit 1: The Lanes

Basic display setup with copper list and machine takeover.

## What This Unit Covers

- Amiga custom chip architecture
- Machine takeover (disabling OS)
- Copper list programming
- Display window configuration
- Vertical blank synchronisation

## Building

```bash
vasmm68k_mot -Fhunkexe -o hop hop.asm
```

## Running

Load `hop` in an emulator or real hardware. Coloured lanes display as background. Left mouse button exits.

## Key Concepts Introduced

| Concept | Description |
|---------|-------------|
| Custom chips | $DFF000 base for display hardware |
| Copper list | Display list executed per scanline |
| DMACON | DMA control for copper, bitplanes, sprites |
| VPOS wait | Synchronise to vertical blank |

## Machine Takeover

```asm
move.w  #$7fff,INTENA(a5)   ; Disable all interrupts
move.w  #$7fff,DMACON(a5)   ; Disable all DMA
```

## Files

- `hop.asm` - Assembly source
- `hop` - Compiled Amiga executable
