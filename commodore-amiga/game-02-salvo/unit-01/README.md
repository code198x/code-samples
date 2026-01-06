# Unit 1: Display Setup

Establish the playfield with copper list.

## What This Unit Covers

- Taking over the system
- Setting up bitplanes
- Basic copper list for background

## Key Concepts

| Concept | Description |
|---------|-------------|
| System takeover | Disable OS, DMA, interrupts |
| Bitplane setup | Point to display memory |
| Copper list | Background colour setup |
| Display dimensions | 320×256 PAL standard |

## System Takeover

```asm
    move.w  #$7FFF,INTENA       ; Disable interrupts
    move.w  #$7FFF,DMACON       ; Disable DMA
    move.w  #$7FFF,INTREQ       ; Clear pending

    ; Save system state for clean exit
    move.l  $4.w,a6             ; ExecBase
    lea     gfxname(pc),a1
    moveq   #0,d0
    jsr     -552(a6)            ; OpenLibrary
    move.l  d0,gfxbase
```

## Copper List

```asm
copperlist:
    dc.w    $0180,$0008         ; Background: dark blue
    dc.w    $FFFF,$FFFE         ; End of copper list
```

## Expected Result

Dark blue screen with system fully under program control.

## Building

```bash
vasmm68k_mot -Fhunkexe -o salvo salvo.asm
```

## Files

- `salvo.asm` - Assembly source
- `salvo` - Compiled executable
