# Grid Protocol - Lesson 10: Sprite Animation Frames

## Overview
This lesson adds animation to your sprite! The character now cycles through different frames while walking, creating the illusion of movement. Combined with the smooth interpolation from lesson 9, this creates professional-looking character animation.

## What's New
- **4 Animation frames**: Idle stance + 3 walking frames
- **Animation cycling**: Frames change every 4 screen updates while moving
- **Direction awareness**: Sprite faces left or right based on movement
- **State-based animation**: Different animations for idle vs moving

## Key Concepts
- **Frame animation**: Cycling through different sprite patterns
- **Animation timing**: Controlling animation speed independently of movement
- **Sprite pointers**: Switching between different sprite data blocks
- **Direction flipping**: Using hardware sprite flip for left/right facing

## Building and Running
```bash
make clean
make all
make run
```

## Controls
- Joystick in port 2 to move
- Sprite animates automatically while moving
- Returns to idle frame when stopped
- Faces the direction of movement

## Technical Details
- 4 frames stored at $0340, $0380, $03C0, $0400
- Animation speed: Changes frame every 4 screen updates
- Sprite shows simple walking animation with leg movement
- Frame counter shows current animation frame (0-3)