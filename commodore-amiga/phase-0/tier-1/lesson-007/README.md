# Lesson 007: First BOB

Introduction to BOBs (Blitter OBjects) - Amiga's hardware-accelerated sprite system.

## Files

- `first-bob.amos` - Create and display your first BOB sprite

## Concepts

- **Screen Open**: Initialize graphics screen with mode and colours
- **BOBs (Blitter OBjects)**: Hardware-accelerated sprites using Amiga's blitter
- **Get Bob**: Capture screen area as reusable sprite image
- **Paste Bob**: Display BOB at any screen position
- **Hardware acceleration**: Blitter copies graphics instantly

## What are BOBs?

BOBs are AMOS's sprite system that uses the Amiga's hardware blitter (bit block transfer) chip for lightning-fast graphics operations. They're different from the Amiga's 8 hardware sprites - BOBs can have hundreds on screen.

**Key features:**
- Hardware-accelerated (uses blitter chip)
- Any size (not limited to 16x16)
- 32 colours in low-res mode
- Instant copying to screen
- Collision detection built-in

## Screen Modes

```amos
Screen Open 0,320,256,32,Lowres
```

**Parameters:**
- Screen ID: 0 (can have multiple screens)
- Width: 320 pixels (low-res) or 640 (high-res)
- Height: 256 lines (PAL standard)
- Colours: 32 (low-res) or 16 (high-res)
- Mode: Lowres or Hires

## BOB Workflow

1. **Draw graphics** using Bar, Circle, Draw commands
2. **Capture as BOB** with `Get Bob number,x1,y1 To x2,y2`
3. **Display BOB** with `Paste Bob x,y,number`
4. **Reuse BOB** anywhere on screen instantly

## Running

1. Load AMOS Professional
2. Load `first-bob.amos`
3. Press F1 to run
4. Watch BOB creation and display process
5. See hardware blitter performance

## Hardware Used

**Agnus**: Memory management and blitter control
**Blitter**: High-speed block copy (graphics operations)
**Denise**: Video display processor

The blitter can copy graphics while the CPU does other work - true parallel processing!

## Extensions

Try:
- Create different sprite designs
- Make larger BOBs (32x32, 64x64)
- Capture multiple animation frames
- Create sprite sheets
- Use more colours in palette
