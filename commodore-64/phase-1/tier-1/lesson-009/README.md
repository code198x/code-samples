# Grid Protocol - Lesson 9: Smooth Linear Interpolation

## Overview
This lesson introduces smooth movement between grid positions using linear interpolation. Instead of instantly snapping to the next grid cell, the sprite now glides smoothly.

## What's New
- **Linear interpolation**: Sprite moves 2 pixels per frame between grid positions
- **Movement states**: IDLE when ready for input, MOVING during interpolation
- **Separate position tracking**: Current position vs target position
- **Smooth visual experience**: No more jarring teleportation

## Key Concepts
- **Interpolation**: Gradual transition between two values over time
- **State machines**: Managing different movement phases
- **Position buffering**: Tracking where we are vs where we're going

## Building and Running
```bash
make clean
make all
make run
```

## Controls
- Joystick in port 2 to move
- Movement only accepted when sprite is idle (not mid-movement)
- Sprite glides smoothly to target grid position

## Technical Details
- Movement speed: 2 pixels per frame
- Grid: 12×8 cells
- Visual feedback: Asterisk (*) appears during movement