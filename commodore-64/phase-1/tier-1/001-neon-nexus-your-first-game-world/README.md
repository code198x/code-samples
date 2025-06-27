# Lesson 1: Neon Nexus - Your First Game World

This folder contains all the code examples for Lesson 1, which introduces the basics of C64 assembly programming and creates the foundation of the Neon Nexus game world.

## Files

- **`complete.s`** - The final program with arena setup and ready indicator
- **`step1-minimal.s`** - Absolute minimal program (does nothing visible)
- **`step2-border-color.s`** - First visible change (red border)
- **`step6-basic-stub.s`** - BASIC area program that can use RUN command

## Building

All examples require ACME assembler:

```bash
# Install ACME (macOS)
brew install acme

# Assemble any example
acme -f cbm -o neon1.prg complete.s

# Run in VICE emulator
x64sc neon1.prg
```

## Features Demonstrated

- **Basic 6502 assembly syntax** (LDA, STA, JSR, RTS)
- **Memory-mapped hardware control** (border and background colors)
- **BASIC stub creation** for auto-run programs
- **KERNAL routine usage** for screen clearing
- **Subroutine organization** for clean code structure

## Progression

Each file demonstrates key concepts:

1. **Step 1**: Minimal program structure and memory loading
2. **Step 2**: First hardware control (border color change)  
3. **Step 6**: BASIC area programming with proper stub
4. **Complete**: Well-organized program with subroutines

## What You'll See

- **Dark blue border** with black background
- **Clear screen** on startup
- **White star** in top-left corner as ready indicator

This creates the visual foundation for the Neon Nexus game world!