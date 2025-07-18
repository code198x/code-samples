# Pixel Patrol - Lesson 4: Basic Sprite Movement

This lesson implements basic sprite movement with joystick control. Your sprite now responds to player input and moves smoothly across the screen in any direction.

### What You'll Learn

- Reading joystick input and mapping to movement
- Direct pixel-based sprite positioning
- Continuous movement while input is held
- Basic sprite position updates
- Foundation for more complex movement systems

### New Concepts Introduced

#### Direct Movement
```assembly
; Move sprite based on joystick
lda sprite_y
sec
sbc #2                 ; Move 2 pixels up
sta sprite_y
```

The sprite moves directly in response to joystick input, changing position by 2 pixels per frame in the pressed direction.

#### Joystick Reading
- **Port 2**: Standard game port on C64
- **Bit Pattern**: Each bit represents a direction
- **Active Low**: Bit clear (0) means pressed
- **Continuous**: Movement while held

### Technical Details

#### Movement System
- **Pixel-Based**: Direct X/Y coordinate tracking
- **Speed**: 2 pixels per frame (smooth movement)
- **Free Movement**: No constraints or boundaries yet
- **Immediate Response**: No delays or state machines

#### Input Mapping
- Bit 0: Up
- Bit 1: Down  
- Bit 2: Left
- Bit 3: Right
- Bit 4: Fire (not used yet)

### Building and Running

```bash
make        # Build the program
make run    # Build and run in VICE emulator
make clean  # Clean build files
```

### Controls
- **Joystick Port 2**: Move sprite in any direction
- **Q/A/O/P Keys**: Alternative keyboard controls
- **Movement**: Continuous while pressed

### What You'll Experience

When you run this program, you'll see:
- **Responsive Sprite**: Moves immediately on input
- **Smooth Motion**: 2 pixels per frame movement
- **Free Movement**: Can go anywhere on screen
- **Diagonal Movement**: Combine directions for 8-way movement

### Foundation for Future Lessons

This basic movement system will be enhanced in upcoming lessons:
- **Lesson 5**: Grid position system for structured movement
- **Lesson 6**: Sprite-to-grid position mapping
- **Lesson 7**: Movement constraints and boundaries
- **Lesson 8**: Proper game loop structure

### Code Architecture

The program demonstrates:
- **Clean Input Handling**: Separate joystick reading
- **Simple Movement Logic**: Direct position updates
- **Modular Functions**: Clear separation of concerns
- **Expandable Design**: Easy to add features

This lesson provides the foundation for all sprite movement in your C64 games, establishing responsive controls that feel good to players.