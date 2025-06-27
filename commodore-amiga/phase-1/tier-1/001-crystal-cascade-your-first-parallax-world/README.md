# Lesson 1: Crystal Cascade - Your First Parallax World

This folder contains all the code examples for Lesson 1, which teaches Amiga 68000 assembly programming and bitplane graphics through creating a stunning parallax scrolling world.

## Files

- **`complete.s`** - Final parallax world with three-layer scrolling and crystal animation
- **`step1-minimal.s`** - Minimal Amiga program structure that runs and exits cleanly
- **`step3-bitplanes.s`** - Basic bitplane setup with three graphics layers and color palette
- **`step7-parallax.s`** - Full parallax scrolling system with animated crystals

## Building

All examples require VASM assembler for 68000 cross-development:

```bash
# Install VASM (macOS) - build from source
curl -O http://sun.hasenbraten.de/vasm/release/vasm.tar.gz
tar xzf vasm.tar.gz
cd vasm
make CPU=m68k SYNTAX=mot
sudo cp vasm68k_mot /usr/local/bin/

# Assemble any example
vasm68k_mot -Fhunkexe -o crystal1 complete.s

# Install FS-UAE Amiga emulator
# Option 1: Homebrew (if available)
brew install --cask fs-uae-launcher

# Option 2: Direct download
# Visit https://fs-uae.net/download

# Run assembled program in FS-UAE
# Copy crystal1 to virtual Amiga and run from Shell
```

## Features Demonstrated

- **68000 Assembly Programming** with Motorola syntax
- **Amiga System Architecture** including ExecBase and graphics.library
- **Custom Chip Programming** (Agnus, Denise registers)
- **Bitplane Graphics System** with multiple independent layers
- **Parallax Scrolling Effects** at different speeds per layer
- **Color Palette Management** with 8-color display mode
- **Hardware Sprites and Animation** using custom chip registers
- **DMA Control** for graphics hardware coordination

## Progression

Each file demonstrates increasing complexity:

1. **Step 1**: Basic Amiga program that initializes and exits properly
2. **Step 3**: Graphics system initialization with bitplane setup
3. **Step 7**: Full parallax system with three scrolling layers
4. **Complete**: Enhanced version with improved crystal patterns and smoother animation

## What You'll See

- **Three-layer parallax world** with crystals at different depths
- **Background layer** - distant crystals scrolling slowly (1 pixel/frame)  
- **Midground layer** - medium crystals at moderate speed (2 pixels/frame)
- **Foreground layer** - large crystals moving fastest (4 pixels/frame)
- **Animated crystal effects** with color cycling and energy pulses
- **Retro color palette** inspired by classic Amiga demos

## Key Concepts

- **Bitplane Architecture**: How the Amiga creates rich graphics from separate bit layers
- **Custom Chip Registers**: Direct hardware programming for maximum performance
- **68000 Addressing Modes**: Efficient data movement and manipulation
- **Frame Synchronization**: Using WaitTOF() for smooth 50Hz animation
- **Memory Management**: Proper system resource allocation and cleanup

## Hardware Registers Used

| Register | Address | Purpose |
|----------|---------|---------|
| `DMACON` | `$dff096` | DMA control (enables graphics) |
| `BPLCON0` | `$dff100` | Bitplane configuration |
| `BPLCON1` | `$dff102` | Horizontal scroll control |
| `BPLxPTH/L` | `$dff0e0+` | Bitplane data pointers |
| `COLORxx` | `$dff180+` | Color palette registers |

## Graphics Data Format

Each bitplane contains 1 bit per pixel:
- **3 bitplanes = 8 colors** (2³ combinations)
- **Each word = 16 pixels** across the screen
- **Multiple words per row** create full-width displays
- **Different layers scroll independently** for parallax depth

## Crystal Pattern Design

The crystal formations use carefully designed bit patterns:

```m68k
; Background: Sparse, distant crystals
dc.w    $0100,$0000,$0000,$0000,$0000,$0000,$0000,$0080

; Midground: Medium-sized formations  
dc.w    $0000,$0400,$0000,$0000,$0000,$0000,$0020,$0000

; Foreground: Large, dramatic crystals
dc.w    $1000,$0000,$0000,$0000,$0000,$0000,$0000,$0008
```

## System Integration

- **Proper library opening/closing** with graphics.library
- **Hardware ownership** via OwnBlitter()/DisownBlitter()  
- **Clean exit handling** returning control to AmigaDOS
- **Frame synchronization** preventing screen tearing

Perfect for demonstrating Amiga graphics capabilities at user group meetings! 🎮✨

## Next Steps

This foundation prepares you for:
- **Hardware sprites** for player entities
- **Copper programming** for advanced effects  
- **Audio integration** with Paula sound chip
- **Input handling** for interactive gameplay