# Unit 2: Custom Font

Design and install user-defined graphics.

## What This Unit Covers

- UDG (User Defined Graphics) concept
- Designing 8×8 characters
- Installing UDG set

## Key Concepts

| Concept | Description |
|---------|-------------|
| UDG location | System variable at $5C7B points to UDGs |
| Character codes | 144-164 ($90-$A4) for UDGs |
| 8 bytes per char | Each byte is one row of pixels |
| Design | Draw on 8×8 grid, convert to bytes |

## UDG Design Example

Brick character:
```
########  = $FF
#......#  = $81
#......#  = $81
########  = $FF
########  = $FF
#......#  = $81
#......#  = $81
########  = $FF
```

## Installation

```asm
install_udg:
    ld hl, udg_data
    ld de, $F000        ; UDG area (above RAMTOP)
    ld bc, 168          ; 21 chars × 8 bytes
    ldir
    ld hl, $F000
    ld ($5C7B), hl      ; Point UDG system var
    ret

udg_data:
    ; Brick character
    defb $FF, $81, $81, $FF, $FF, $81, $81, $FF
```

## Expected Result

Custom brick and other game characters available for printing.

## Building

```bash
pasmonext --tapbas shatter.asm shatter.tap
```

## Files

- `shatter.asm` - Assembly source
- `shatter.tap` - Tape image
