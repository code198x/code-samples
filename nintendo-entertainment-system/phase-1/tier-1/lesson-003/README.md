# Lesson 003: CPU and Memory Map

Code samples for understanding 6502 CPU, NES memory layout, and zero page variables.

## Files

- `variables.asm` - Using zero page for fast variable access

## Building

```bash
ca65 variables.asm -o variables.o
ld65 variables.o -C nes.cfg -o variables.nes
```

## Key Concepts

- Zero page ($00-$FF) provides fastest memory access (3 cycles vs 4 for absolute)
- Stack at $0100-$01FF
- OAM buffer conventionally at $0200-$02FF
- General RAM at $0300-$07FF
- PRG-ROM at $8000-$FFFF

## 6502 Registers

- **A** (Accumulator) - arithmetic and logic operations
- **X, Y** (Index registers) - array access, counters
- **SP** (Stack Pointer) - points to $0100-$01FF
- **PC** (Program Counter) - current instruction address
