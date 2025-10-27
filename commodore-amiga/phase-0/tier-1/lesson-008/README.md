# Lesson 008: Screen Artist

Master the Amiga's hardware-accelerated drawing commands and colour palette system.

## Files

- `screen-artist.amos` - Drawing commands showcase and sprite creation

## Concepts

- **Drawing commands**: Plot, Draw, Circle, Bar, Box
- **Colour system**: Ink, Paper, Cls for colour control
- **Palette programming**: Colour command with RGB values
- **Hardware acceleration**: All drawing uses blitter
- **RGB colour model**: 4-bit per channel (0-15 range)

## Drawing Commands

### Plot - Single Pixel
```amos
Plot x,y           ' Draw pixel at position
```

### Draw - Lines
```amos
Plot x1,y1         ' Start position
Draw x2,y2         ' Draw line to new position
```

### Circle - Rings and Filled
```amos
Circle x,y,radius  ' Draw circle
```

### Bar - Filled Rectangle
```amos
Bar x1,y1 To x2,y2  ' Draw filled rectangle
```

### Box - Rectangle Outline
```amos
Box x1,y1 To x2,y2  ' Draw outline only
```

## Colour System

### Ink and Paper
```amos
Ink 1              ' Set foreground colour
Paper 2            ' Set background colour
```

### Palette Programming
```amos
Colour index,$RGB  ' Set palette entry

' Examples:
Colour 1,$F00      ' Bright red (R=15, G=0, B=0)
Colour 2,$0F0      ' Bright green (R=0, G=15, B=0)
Colour 3,$00F      ' Bright blue (R=0, G=0, B=15)
Colour 4,$FF0      ' Yellow (red + green)
Colour 5,$F0F      ' Magenta (red + blue)
Colour 6,$0FF      ' Cyan (green + blue)
Colour 7,$FFF      ' White (all maximum)
Colour 8,$800      ' Dark red (R=8, others 0)
```

**RGB Format:** `$RGB` where R, G, B are hex digits (0-F)
- Each channel: 0 (off) to F (maximum, value 15)
- 4 bits per channel = 4096 possible colours
- 32 colours available in low-res mode

## Hardware Acceleration

All drawing commands use the Amiga's blitter:
- **Instant drawing** - no CPU overhead
- **Pattern fills** - hardware-supported
- **Fast copying** - parallel to CPU operation

This is why AMOS graphics are so much faster than C64 or Spectrum!

## Running

1. Load AMOS Professional
2. Load `screen-artist.amos`
3. Press F1 to run
4. Watch progressive drawing demonstration
5. See sprite creation process
6. Press SPACE to see BOB display

## Hardware Used

**Blitter**: All drawing operations (Plot, Draw, Bar, Circle, Box)
**Copper**: Palette management
**Denise**: Display output

## Extensions

Try:
- Create rainbow gradients with Colour loops
- Draw complex patterns with nested For loops
- Create animated colour cycling
- Design detailed sprites (32x32 or larger)
- Make sprite animation frames
- Create tile graphics for games
