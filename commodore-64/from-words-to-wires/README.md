# From Words to Wires – Code Samples

Code samples for the "From Words to Wires" transition course.

## Structure

- **week-1/**: 8-lesson bridge from BASIC to Assembly
  - Lesson 1: BASIC interpreter tracer
  - Lesson 4: ACME assembler examples (blinker.asm)
  - Lesson 8: Hybrid Scroll Runner (assembly core + BASIC orchestration)

## Building Assembly Files

Assembly files (`.asm`) require ACME assembler:

```bash
# Using Docker (recommended)
docker-compose up -d
docker-compose exec workspace bash
cd /workspace/code-samples/commodore-64/from-words-to-wires/week-1
acme -f cbm -o blinker.prg lesson-04-blinker.asm

# Or with local ACME install
acme -f cbm -o blinker.prg lesson-04-blinker.asm
```

## Loading in VICE

```bash
# Load PRG directly
x64sc blinker.prg

# Or from BASIC
LOAD"BLINKER",8,1
SYS 49152
```

## Lesson-Specific Notes

### Lesson 1: Trace the Interpreter
`lesson-01-tracer.bas` - Run this program and then call line 900 (`GOSUB 900`) to see BASIC's memory layout.

### Lesson 4: Machine Code Tooling
- `lesson-04-blinker.asm` - Assembly color cycler
- `lesson-04-timing.bas` - Compares BASIC vs assembly speed

Assemble blinker first, then run the timing BASIC program with the PRG loaded.

### Lesson 8: Capstone
- `lesson-08-scroll-core.asm` - Scroll Runner render loop in assembly
- `lesson-08-hybrid.bas` - BASIC orchestration calling assembly routine

This demonstrates the hybrid pattern: BASIC handles game logic, assembly handles rendering.

## Prerequisites

- VICE emulator (https://vice-emu.sourceforge.io/)
- ACME assembler (https://github.com/meonwax/acme)
- OR use the provided Docker environment

## See Also

- [C64 BASIC Course](/commodore-64/basic) - Complete before this course
- [Assembly Course](/commodore-64/assembly) - Continue after this course
